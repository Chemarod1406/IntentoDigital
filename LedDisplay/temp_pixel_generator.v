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
    wire [4:0] row = pixel_addr[11:6];  // CORREGIDO: bits [11:6] para ROW[4:0]
    wire [5:0] col = pixel_addr[5:0];   // CORREGIDO: bits [5:0] para COL[5:0]
    
    // Dígitos BCD de temperatura
    wire [3:0] c_tens = celsius / 10;
    wire [3:0] c_ones = celsius % 10;
    wire [3:0] f_tens = fahrenheit / 10;
    wire [3:0] f_ones = fahrenheit % 10;
    
    // Fuente de caracteres 5x7 para dígitos
    wire [6:0] digit_c_tens, digit_c_ones;
    wire [6:0] digit_f_tens, digit_f_ones;
    
    // Usar solo los bits necesarios de row para indexar la fuente
    wire [2:0] char_row = row[2:0];
    
    digit_5x7_rom rom_c_tens(.digit(c_tens), .row(char_row), .pixel_row(digit_c_tens));
    digit_5x7_rom rom_c_ones(.digit(c_ones), .row(char_row), .pixel_row(digit_c_ones));
    digit_5x7_rom rom_f_tens(.digit(f_tens), .row(char_row), .pixel_row(digit_f_tens));
    digit_5x7_rom rom_f_ones(.digit(f_ones), .row(char_row), .pixel_row(digit_f_ones));
    
    // Posiciones de texto en la pantalla (centrado en 64x64)
    localparam TEXT_START_ROW = 28;
    localparam TEXT_END_ROW = 35;    // 7 filas para caracteres 5x7
    
    localparam C_TENS_COL = 18;
    localparam C_ONES_COL = 24;
    localparam C_SYMBOL_COL = 30;
    localparam F_TENS_COL = 36;
    localparam F_ONES_COL = 42;
    localparam F_SYMBOL_COL = 48;
    
    // Colores RGB (formato: RRRRGGGGBBBB en 12 bits, expandido a 24)
    localparam [23:0] COLOR_CELSIUS = 24'hFF0000;    // Rojo
    localparam [23:0] COLOR_FAHRENHEIT = 24'h0000FF; // Azul
    localparam [23:0] COLOR_BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    wire [2:0] font_row = row - TEXT_START_ROW;
    
    // Índices de columna dentro de cada dígito
    wire [2:0] c_tens_idx = col - C_TENS_COL;
    wire [2:0] c_ones_idx = col - C_ONES_COL;
    wire [2:0] f_tens_idx = col - F_TENS_COL;
    wire [2:0] f_ones_idx = col - F_ONES_COL;
    
    always @(*) begin
        pixel_data = COLOR_BLACK;  // Fondo negro por defecto
        
        if (in_text_row && font_row < 7) begin
            // Mostrar dígito decenas Celsius
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[4 - c_tens_idx])  // CORREGIDO: invertir índice
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar dígito unidades Celsius
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[4 - c_ones_idx])
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar símbolo °C (simplificado: pequeño círculo + C)
            else if (col >= C_SYMBOL_COL && col < (C_SYMBOL_COL + 4)) begin
                // Pequeño círculo para grados
                if (font_row <= 2 && (col == C_SYMBOL_COL || col == C_SYMBOL_COL + 1))
                    pixel_data = COLOR_CELSIUS;
                // Letra C
                else if (font_row >= 1 && col >= C_SYMBOL_COL + 2)
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar dígito decenas Fahrenheit
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[4 - f_tens_idx])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Mostrar dígito unidades Fahrenheit
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[4 - f_ones_idx])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Mostrar símbolo °F
            else if (col >= F_SYMBOL_COL && col < (F_SYMBOL_COL + 4)) begin
                // Pequeño círculo para grados
                if (font_row <= 2 && (col == F_SYMBOL_COL || col == F_SYMBOL_COL + 1))
                    pixel_data = COLOR_FAHRENHEIT;
                // Letra F
                else if (font_row >= 1 && col >= F_SYMBOL_COL + 2)
                    pixel_data = COLOR_FAHRENHEIT;
            end
        end
    end

endmodule