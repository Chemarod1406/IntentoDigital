`timescale 1ns / 1ps
module led_temp_simple(
    input         clk,
    input         rst,
    input [7:0]   temp_c,
    input [7:0]   temp_f,
    
    output        LP_CLK,
    output        LATCH,
    output        NOE,
    output [4:0]  ROW,
    output [2:0]  RGB0,
    output [2:0]  RGB1
);

    wire w_ZR, w_ZC, w_ZD, w_ZI;
    wire w_LD, w_SHD;
    wire w_RST_R, w_RST_C, w_RST_D, w_RST_I;
    wire w_INC_R, w_INC_C, w_INC_D, w_INC_I;
    wire [10:0] count_delay;
    wire [10:0] delay;
    wire [1:0] index;
    wire PX_CLK_EN;
    
    wire [5:0] COL;
    wire [11:0] PIX_ADDR;
    wire [23:0] pixel_data;
    
    wire tmp_noe, tmp_latch;
    assign LATCH = ~tmp_latch;
    assign NOE = tmp_noe;

    reg clk1;
    reg [4:0] clk_counter;
    
    always @(posedge clk) begin
        if (rst) begin
            clk_counter <= 0;
            clk1 <= 0;
        end else begin
            if (clk_counter == 2) begin
                clk1 <= ~clk1;
                clk_counter <= 0;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end
    
    assign PIX_ADDR = {ROW, COL};
    assign LP_CLK = clk1 & PX_CLK_EN;
    assign delay = 11'd10;  // DELAY FIJO en lugar de shift register

    count #(.width(5))  count_row(
        .clk(clk1),
        .reset(w_RST_R),
        .inc(w_INC_R),
        .outc(ROW),
        .zero(w_ZR)
    );
    
    count #(.width(6))  count_col(
        .clk(clk1),
        .reset(w_RST_C),
        .inc(w_INC_C),
        .outc(COL),
        .zero(w_ZC)
    );
    
    count #(.width(11)) cnt_delay(
        .clk(clk1),
        .reset(w_RST_D),
        .inc(w_INC_D),
        .outc(count_delay)
    );
    
    count #(.width(2)) count_index(
        .clk(clk1),
        .reset(w_RST_I),
        .inc(w_INC_I),
        .outc(index),
        .zero(w_ZI)
    );
    
    comp_4k #(.width(11)) compa(
        .in1(delay),
        .in2(count_delay),
        .out(w_ZD)
    );
    
    // Patrón simple: Rojo arriba, Azul abajo
    wire [4:0] row_pos = PIX_ADDR[10:6];
    wire upper_half = (row_pos < 16);
    assign pixel_data = upper_half ? 24'hFF0000 : 24'h0000FF;
    
    mux_led mux0(
        .in0(pixel_data),
        .out0({RGB0, RGB1}),
        .sel(index)
    );
    
    ctrl_lp4k ctrl0(
        .clk(clk1),
        .rst(rst),
        .init(1'b1),
        .ZR(w_ZR),
        .ZC(w_ZC),
        .ZD(w_ZD),
        .ZI(w_ZI),
        .RST_R(w_RST_R),
        .RST_C(w_RST_C),
        .RST_D(w_RST_D),
        .RST_I(w_RST_I),
        .INC_R(w_INC_R),
        .INC_C(w_INC_C),
        .INC_D(w_INC_D),
        .INC_I(w_INC_I),
        .LD(w_LD),
        .SHD(w_SHD),
        .LATCH(tmp_latch),
        .NOE(tmp_noe),
        .PX_CLK_EN(PX_CLK_EN)
    );

endmodule