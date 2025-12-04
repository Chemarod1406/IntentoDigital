`timescale 1ns / 1ps
module temp_display_top(
    input         clk,          // 25MHz clock
    input         rst,          // Reset button (activo BAJO por el PULLUP)
    
    // I2C Interface (Sensor LM75)
    inout         I2C_SDA,
    output        I2C_SCL,
    
    // LED Matrix Interface
    output        LP_CLK,
    output        LATCH,
    output        NOE,
    output [4:0]  ROW,
    output [2:0]  RGB0,
    output [2:0]  RGB1
);

    // =========================================================================
    // SINCRONIZACIÓN Y LIMPIEZA DEL RESET EXTERNO
    // =========================================================================
    reg [2:0] rst_sync = 3'b111;
    
    always @(posedge clk) begin
        rst_sync <= {rst_sync[1:0], rst};  // Sincronizar con reloj
    end
    
    wire rst_button = rst_sync[2];  // Reset limpio y sincronizado

    // =========================================================================
    // GENERADOR DE RESET AUTOMÁTICO (Power-On Reset)
    // =========================================================================
    // Mantiene reset por ~65ms al encender para estabilizar todo
    reg [20:0] reset_counter = 0;
    reg        auto_rst = 1;

    always @(posedge clk) begin
        if (reset_counter < 21'd1_600_000) begin  // 64ms @ 25MHz
            reset_counter <= reset_counter + 1;
            auto_rst <= 1;
        end else begin
            auto_rst <= 0;
        end
    end

    // Reset final: Automático OR botón presionado
    // Como el botón tiene PULLUP, está en 1 normalmente y va a 0 al presionar
    wire sys_rst = auto_rst | ~rst_button;  // Reset cuando auto_rst=1 o botón presionado (rst=0)

    // =========================================================================
    // INTERFAZ SENSOR I2C
    // =========================================================================
    wire w_200KHz;
    wire [7:0] c_data;    
    wire [7:0] f_data;    
    
    i2c_master i2c_temp_sensor(
        .clk_200KHz(w_200KHz),
        .temp_data(c_data),
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );
    
    clkgen_200KHz clkgen(
        .clk_25MHz(clk),
        .clk_200KHz(w_200KHz)
    );
    
    temp_converter tempconv(
        .c(c_data),
        .f(f_data)
    );

    // =========================================================================
    // CONTROLADOR MATRIZ LED
    // =========================================================================
    
    led_panel_temp_display matrix_ctrl(
        .clk(clk),
        .rst(sys_rst),      
        .init(~sys_rst),    // Init se activa cuando NO hay reset
        .c_val(c_data),     
        .f_val(f_data),     
        .LP_CLK(LP_CLK),
        .LATCH(LATCH),
        .NOE(NOE),
        .ROW(ROW),
        .RGB0(RGB0),
        .RGB1(RGB1)
    );

endmodule