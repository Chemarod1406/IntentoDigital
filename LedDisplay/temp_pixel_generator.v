`timescale 1ns / 1ps
module temp_pixel_generator(
    input clk,
    input rst,
    input [7:0] celsius,
    input [7:0] fahrenheit,
    input [11:0] pixel_addr,  // {ROW[4:0], COL[5:0]}
    output reg [23:0] pixel_data
);

    // Extraer coordenadas
    wire [4:0] row = pixel_addr[10:6];  
    wire [5:0] col = pixel_addr[5:0];   
    
    // Dígitos BCD de temperatura
    wire [3:0] c_tens = celsius / 10;
    wire [3:0] c_ones = celsius % 10;
    wire [3:0] f_tens = fahrenheit / 10;
    wire [3:0] f_ones = fahrenheit % 10;
    
    // Fuente de caracteres 5x7 para dígitos
    wire [6:0] digit_c_tens, digit_c_ones;
    wire [6:0] digit_f_tens, digit_f_ones;
    
    // Usar solo los bits necesarios de row para indexar la fuente (0-6 para 7 filas)
    wire [2:0] char_row = row[2:0];
    
    digit_5x7_rom rom_c_tens(.digit(c_tens), .row(char_row), .pixel_row(digit_c_tens));
    digit_5x7_rom rom_c_ones(.digit(c_ones), .row(char_row), .pixel_row(digit_c_ones));
    digit_5x7_rom rom_f_tens(.digit(f_tens), .row(char_row), .pixel_row(digit_f_tens));
    digit_5x7_rom rom_f_ones(.digit(f_ones), .row(char_row), .pixel_row(digit_f_ones));
    
    // Posiciones de texto en la pantalla
    localparam TEXT_START_ROW = 5;    // Más arriba para evitar mitad inferior
    localparam TEXT_END_ROW = 12;     // 7 filas para caracteres 5x7
    
    // Posiciones horizontales - MEJOR ESPACIADO
    localparam C_TENS_COL = 6;        // Celsius decenas
    localparam C_ONES_COL = 12;       // Celsius unidades  
    localparam C_SYMBOL_COL = 18;     // Símbolo °C
    
    localparam F_TENS_COL = 36;       // Fahrenheit decenas
    localparam F_ONES_COL = 42;       // Fahrenheit unidades
    localparam F_SYMBOL_COL = 48;     // Símbolo °F
    
    // Colores RGB (8 bits por canal)
    localparam [23:0] COLOR_CELSIUS = 24'hFF0000;    // Rojo
    localparam [23:0] COLOR_FAHRENHEIT = 24'h0000FF; // Azul
    localparam [23:0] COLOR_BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    wire [2:0] font_row = row - TEXT_START_ROW;
    
    always @(*) begin
        pixel_data = COLOR_BLACK;  // Fondo negro
        
        if (in_text_row && font_row < 7) begin
            // Dígito decenas Celsius
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[6 - (col - C_TENS_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Dígito unidades Celsius
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[6 - (col - C_ONES_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Símbolo °C
            else if (col >= C_SYMBOL_COL && col < (C_SYMBOL_COL + 4)) begin
                if (font_row <= 2 && (col - C_SYMBOL_COL) <= 1)
                    pixel_data = COLOR_CELSIUS;
            end
            // Dígito decenas Fahrenheit
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[6 - (col - F_TENS_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Dígito unidades Fahrenheit
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[6 - (col - F_ONES_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Símbolo °F
            else if (col >= F_SYMBOL_COL && col < (F_SYMBOL_COL + 4)) begin
                if (font_row <= 2 && (col - F_SYMBOL_COL) <= 1)
                    pixel_data = COLOR_FAHRENHEIT;
            end
        end
    end

endmodule