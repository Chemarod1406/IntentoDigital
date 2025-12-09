`timescale 1ns / 1ps
module temp_pixel_generator(
    input [7:0] celsius,
    input [7:0] fahrenheit,
    input [10:0] pixel_addr,  // {ROW[4:0], COL[5:0]} = 11 bits
    output reg [23:0] pixel_data
);

    wire [4:0] row = pixel_addr[10:6];  // 5 bits para 32 filas
    wire [5:0] col = pixel_addr[5:0];   // 6 bits para 64 columnas
    
    wire [3:0] c_tens = celsius / 10;
    wire [3:0] c_ones = celsius % 10;
    wire [3:0] f_tens = fahrenheit / 10;
    wire [3:0] f_ones = fahrenheit % 10;
    
    wire [6:0] digit_c_tens, digit_c_ones;
    wire [6:0] digit_f_tens, digit_f_ones;
    
    localparam TEXT_START_ROW = 12;
    localparam TEXT_END_ROW = 19;
    
    wire [2:0] font_row = row - TEXT_START_ROW;
    
    localparam C_TENS_COL = 8;
    localparam C_ONES_COL = 14;
    localparam C_SYMBOL_COL = 20;  
    
    
    localparam F_TENS_COL = 34;
    localparam F_ONES_COL = 40;
    localparam F_SYMBOL_COL = 46;  // Símbolo °F
    
    digit_5x7_rom rom_c_tens(.digit(c_tens), .row(font_row), .pixel_row(digit_c_tens));
    digit_5x7_rom rom_c_ones(.digit(c_ones), .row(font_row), .pixel_row(digit_c_ones));
    digit_5x7_rom rom_f_tens(.digit(f_tens), .row(font_row), .pixel_row(digit_f_tens));
    digit_5x7_rom rom_f_ones(.digit(f_ones), .row(font_row), .pixel_row(digit_f_ones));
    
    localparam [23:0] RED   = 24'hFF0000;
    localparam [23:0] BLUE  = 24'h0000FF;
    localparam [23:0] BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    
    always @(*) begin
        pixel_data = BLACK;
        
        if (in_text_row && font_row < 7) begin
            
            
            
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[5 - (col - C_TENS_COL)])
                    pixel_data = RED;
            end
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[5 - (col - C_ONES_COL)])
                    pixel_data = RED;
            end
            else if (col >= C_SYMBOL_COL && col < (C_SYMBOL_COL + 4)) begin
                case (font_row)
                    3'd0: if (col == C_SYMBOL_COL+1 || col == C_SYMBOL_COL+2) pixel_data = RED;
                    3'd1: if (col == C_SYMBOL_COL) pixel_data = RED;
                    3'd2: if (col == C_SYMBOL_COL) pixel_data = RED;
                    3'd3: if (col == C_SYMBOL_COL) pixel_data = RED;
                    3'd4: if (col == C_SYMBOL_COL) pixel_data = RED;
                    3'd5: if (col == C_SYMBOL_COL) pixel_data = RED;
                    3'd6: if (col == C_SYMBOL_COL+1 || col == C_SYMBOL_COL+2) pixel_data = RED;
                    default: pixel_data = BLACK;
                endcase
            end
            
            
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[5 - (col - F_TENS_COL)])
                    pixel_data = BLUE;
            end
            
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[5 - (col - F_ONES_COL)])
                    pixel_data = BLUE;
            end
           
            else if (col >= F_SYMBOL_COL && col < (F_SYMBOL_COL + 4)) begin
                case (font_row)
                    3'd0: if (col >= F_SYMBOL_COL && col <= F_SYMBOL_COL+2) pixel_data = BLUE;
                    3'd1: if (col == F_SYMBOL_COL) pixel_data = BLUE;
                    3'd2: if (col == F_SYMBOL_COL || col == F_SYMBOL_COL+1) pixel_data = BLUE;
                    3'd3: if (col == F_SYMBOL_COL) pixel_data = BLUE;
                    3'd4: if (col == F_SYMBOL_COL) pixel_data = BLUE;
                    3'd5: if (col == F_SYMBOL_COL) pixel_data = BLUE;
                    3'd6: if (col == F_SYMBOL_COL) pixel_data = BLUE;
                    default: pixel_data = BLACK;
                endcase
            end
        end
    end

endmodule