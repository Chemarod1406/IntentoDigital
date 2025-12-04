`timescale 1ns / 1ps
module led_panel_temp_display(
    input         clk,
    input         rst,
    input         init,
    input [7:0]   c_val,
    input [7:0]   f_val,
    
    output        LP_CLK,
    output        LATCH,
    output        NOE,
    output [4:0]  ROW,
    output [2:0]  RGB0,
    output [2:0]  RGB1
);

    // =========================================================================
    // GENERADOR DE RELOJ PARA LA MATRIZ (~3MHz desde 25MHz)
    // =========================================================================
    reg [2:0] clk_div = 0;
    reg clk_matrix = 0;
    
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
        if (clk_div == 0)
            clk_matrix <= ~clk_matrix;
    end

    // =========================================================================
    // SEÑALES DE LA FSM Y CONTADORES
    // =========================================================================
    wire [4:0] row_count;
    wire [5:0] col_count;
    wire [9:0] delay_count;
    wire [1:0] bit_count;
    
    wire ZR, ZC, ZD, ZI;
    wire RST_R, RST_C, RST_D, RST_I;
    wire INC_R, INC_C, INC_D, INC_I;
    wire LD, SHD, PX_CLK_EN;
    
    // =========================================================================
    // FSM - CONTROLA LA SECUENCIA DE ESCANEO
    // =========================================================================
    ctrl_lp4k fsm(
        .clk(clk_matrix),
        .init(init),
        .rst(rst),
        .ZR(ZR),
        .ZC(ZC),
        .ZD(ZD),
        .ZI(ZI),
        .RST_R(RST_R),
        .RST_C(RST_C),
        .RST_D(RST_D),
        .RST_I(RST_I),
        .INC_R(INC_R),
        .INC_C(INC_C),
        .INC_D(INC_D),
        .INC_I(INC_I),
        .LD(LD),
        .SHD(SHD),
        .LATCH(LATCH),
        .NOE(NOE),
        .PX_CLK_EN(PX_CLK_EN)
    );
    
    // =========================================================================
    // CONTADORES - count.v USA reset ACTIVO ALTO
    // RST_R=1 significa "NO resetear", por eso invertimos con ~RST_R
    // =========================================================================
    count #(.width(5)) cnt_row(
        .clk(clk_matrix),
        .reset(~RST_R),    // Invertir: FSM manda 1=activo, count espera 1=reset
        .inc(INC_R),
        .outc(row_count),
        .zero(ZR)
    );
    
    count #(.width(6)) cnt_col(
        .clk(clk_matrix),
        .reset(~RST_C),
        .inc(INC_C),
        .outc(col_count),
        .zero(ZC)
    );
    
    count #(.width(10)) cnt_delay(
        .clk(clk_matrix),
        .reset(~RST_D),
        .inc(INC_D),
        .outc(delay_count),
        .zero(ZD)
    );
    
    count #(.width(2)) cnt_bit(
        .clk(clk_matrix),
        .reset(~RST_I),
        .inc(INC_I),
        .outc(bit_count),
        .zero(ZI)
    );
    
    // =========================================================================
    // GENERADORES DE PÍXELES
    // *** CORRECCIÓN CRÍTICA: Direccionamiento correcto ***
    // Para matriz 1:16 scan, la mitad superior usa filas 0-15,
    // la mitad inferior usa filas 16-31
    // =========================================================================
    
    // Calcular filas para cada mitad
    wire [4:0] row_upper = row_count;           // Filas 0-31 (mitad superior)
    wire [4:0] row_lower = row_count + 5'd16;   // Filas 16-47 (mitad inferior)
    
    // Construir direcciones completas: {row[4:0], col[5:0]} = 11 bits
    wire [10:0] addr_upper = {row_upper, col_count};
    wire [10:0] addr_lower = {row_lower, col_count};
    
    wire [23:0] pixel_upper, pixel_lower;
    
    temp_pixel_generator gen_upper(
        .clk(clk),
        .rst(rst),
        .celsius(c_val),
        .fahrenheit(f_val),
        .pixel_addr({1'b0, addr_upper}),  // Expandir a 12 bits (11 usados)
        .pixel_data(pixel_upper)
    );
    
    temp_pixel_generator gen_lower(
        .clk(clk),
        .rst(rst),
        .celsius(c_val),
        .fahrenheit(f_val),
        .pixel_addr({1'b0, addr_lower}),
        .pixel_data(pixel_lower)
    );
    
    // =========================================================================
    // REGISTROS DE DESPLAZAMIENTO (Shift Registers)
    // =========================================================================
    wire [23:0] shift_upper, shift_lower;
    reg [23:0] pixel_buffer_upper, pixel_buffer_lower;
    
    // Capturar píxel cuando FSM indica LOAD
    always @(negedge clk_matrix) begin
        if (LD) begin
            pixel_buffer_upper <= pixel_upper;
            pixel_buffer_lower <= pixel_lower;
        end
    end
    
    lsr_led #(.width(24), .init_value(0)) lsr_upper(
        .clk(clk_matrix),
        .shift(SHD),
        .load(LD),
        .data_in(pixel_buffer_upper),
        .s_A(shift_upper)
    );
    
    lsr_led #(.width(24), .init_value(0)) lsr_lower(
        .clk(clk_matrix),
        .shift(SHD),
        .load(LD),
        .data_in(pixel_buffer_lower),
        .s_A(shift_lower)
    );
    
    // =========================================================================
    // MULTIPLEXORES - Selección de bit para PWM de 4 bits
    // =========================================================================
    wire [5:0] mux_upper, mux_lower;
    
    mux_led mux_u(
        .in0(shift_upper),
        .sel(bit_count),
        .out0(mux_upper)
    );
    
    mux_led mux_l(
        .in0(shift_lower),
        .sel(bit_count),
        .out0(mux_lower)
    );
    
    // =========================================================================
    // SALIDAS AL PANEL HUB75
    // *** CORRECCIÓN CRÍTICA: Mapeo correcto de pines RGB ***
    // 
    // HUB75 espera: R0, G0, B0, R1, G1, B1
    // mux_led retorna [5:0]: {R0, G0, B0, R1, G1, B1}
    //   [5] = R0 (rojo mitad superior)
    //   [4] = G0 (verde mitad superior)
    //   [3] = B0 (azul mitad superior)
    //   [2] = R1 (rojo mitad inferior)
    //   [1] = G1 (verde mitad inferior)
    //   [0] = B1 (azul mitad inferior)
    // =========================================================================
    
    assign ROW = row_count;
    assign LP_CLK = PX_CLK_EN ? clk_matrix : 1'b0;
    
    // Extraer RGB para cada mitad de la pantalla
    assign RGB0 = {mux_upper[5], mux_upper[4], mux_upper[3]};  // R0, G0, B0
    assign RGB1 = {mux_lower[2], mux_lower[1], mux_lower[0]};  // R1, G1, B1

endmodule