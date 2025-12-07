`timescale 1ns / 1ps
module temp_pixel_generator(
    input clk,
    input rst,
    input [7:0] celsius,
    input [7:0] fahrenheit,
    input [11:0] pixel_addr,  // {ROW[4:0], COL[5:0]}
    output reg [23:0] pixel_data
);

    // Extraer coordenadas - IGUAL QUE ANTES (lo que funcionaba)
    wire [4:0] row = pixel_addr[10:6];  
    wire [5:0] col = pixel_addr[5:0];   
    
    // Dígitos BCD
    wire [3:0] c_tens = celsius / 10;
    wire [3:0] c_ones = celsius % 10;
    wire [3:0] f_tens = fahrenheit / 10;
    wire [3:0] f_ones = fahrenheit % 10;
    
    // ROMs de fuentes
    wire [6:0] digit_c_tens, digit_c_ones;
    wire [6:0] digit_f_tens, digit_f_ones;
    
    wire [2:0] char_row = row[2:0];
    
    digit_5x7_rom rom_c_tens(.digit(c_tens), .row(char_row), .pixel_row(digit_c_tens));
    digit_5x7_rom rom_c_ones(.digit(c_ones), .row(char_row), .pixel_row(digit_c_ones));
    digit_5x7_rom rom_f_tens(.digit(f_tens), .row(char_row), .pixel_row(digit_f_tens));
    digit_5x7_rom rom_f_ones(.digit(f_ones), .row(char_row), .pixel_row(digit_f_ones));
    
    // POSICIONES SIMPLES - Solo 4 números, bien separados
    localparam TEXT_START_ROW = 12;
    localparam TEXT_END_ROW = 19;
    
    // Celsius: columnas 10-25 (izquierda)
    localparam C_TENS_COL = 10;
    localparam C_ONES_COL = 17;
    
    // Fahrenheit: columnas 35-50 (derecha)
    localparam F_TENS_COL = 35;
    localparam F_ONES_COL = 42;
    
    // Colores
    localparam [23:0] RED = 24'hFF0000;
    localparam [23:0] BLUE = 24'h0000FF;
    localparam [23:0] BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    wire [2:0] font_row = row - TEXT_START_ROW;
    wire [2:0] col_offset;
    
    always @(*) begin
        pixel_data = BLACK;
        
        if (in_text_row && font_row < 7) begin
            // CELSIUS - DECENAS (rojo)
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[6 - (col - C_TENS_COL)])
                    pixel_data = RED;
            end
            // CELSIUS - UNIDADES (rojo)
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[6 - (col - C_ONES_COL)])
                    pixel_data = RED;
            end
            // FAHRENHEIT - DECENAS (azul)
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[6 - (col - F_TENS_COL)])
                    pixel_data = BLUE;
            end
            // FAHRENHEIT - UNIDADES (azul)
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[6 - (col - F_ONES_COL)])
                    pixel_data = BLUE;
            end
        end
    end

endmodule