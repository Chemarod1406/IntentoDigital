`timescale 1ns / 1ps
module temp_pixel_generator(
    input clk,
    input rst,
    input [7:0] celsius,
    input [7:0] fahrenheit,
    input [11:0] pixel_addr,  // {ROW[4:0], COL[5:0]}
    output reg [23:0] pixel_data
);

    // *** CORRECCIÓN CRÍTICA: El orden correcto es ROW en bits altos ***
    wire [4:0] row = pixel_addr[10:6];  // Bits [10:6] = 5 bits para ROW
    wire [5:0] col = pixel_addr[5:0];   // Bits [5:0] = 6 bits para COL
    
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
    
    // Posiciones de texto en la pantalla (centrado verticalmente)
    localparam TEXT_START_ROW = 12;   // Fila 12 (más arriba en la mitad superior)
    localparam TEXT_END_ROW = 19;     // 7 filas para caracteres 5x7
    
    // Posiciones horizontales (centradas en 64 columnas)
    localparam C_TENS_COL = 8;
    localparam C_ONES_COL = 14;
    localparam C_SYMBOL_COL = 20;
    localparam F_TENS_COL = 28;
    localparam F_ONES_COL = 34;
    localparam F_SYMBOL_COL = 40;
    
    // Colores RGB brillantes (8 bits por canal, solo usamos los 4 MSB)
    localparam [23:0] COLOR_CELSIUS = 24'hFF0000;    // Rojo puro
    localparam [23:0] COLOR_FAHRENHEIT = 24'h0000FF; // Azul puro
    localparam [23:0] COLOR_BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    wire [2:0] font_row = row - TEXT_START_ROW;
    
    always @(*) begin
        pixel_data = COLOR_BLACK;  // Fondo negro por defecto
        
        if (in_text_row && font_row < 7) begin
            // *** CORRECCIÓN: Leer bit correcto de la ROM ***
            // digit_rom devuelve 7 bits: [6:0] donde bit 6 = columna izquierda
            
            // Mostrar dígito decenas Celsius
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[6 - (col - C_TENS_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar dígito unidades Celsius
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[6 - (col - C_ONES_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar símbolo °C (simplificado)
            else if (col >= C_SYMBOL_COL && col < (C_SYMBOL_COL + 3)) begin
                if (font_row < 3)  // Pequeño círculo superior
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar dígito decenas Fahrenheit
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[6 - (col - F_TENS_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Mostrar dígito unidades Fahrenheit
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[6 - (col - F_ONES_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Mostrar símbolo °F
            else if (col >= F_SYMBOL_COL && col < (F_SYMBOL_COL + 3)) begin
                if (font_row < 3)
                    pixel_data = COLOR_FAHRENHEIT;
            end
        end
    end

endmodule