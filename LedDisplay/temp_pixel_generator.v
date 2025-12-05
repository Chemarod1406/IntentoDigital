`timescale 1ns / 1ps
module temp_pixel_generator(
    input [7:0] celsius,
    input [7:0] fahrenheit,
    input [11:0] pixel_addr,
    output reg [23:0] pixel_data
);

    // *** CORRECCIÓN CRÍTICA: El formato es {ROW, COL} = {5 bits, 6 bits} ***
    wire [4:0] row = pixel_addr[10:6];  // Bits [10:6] = ROW
    wire [5:0] col = pixel_addr[5:0];   // Bits [5:0] = COL
    
    // Dígitos BCD
    wire [3:0] c_tens = celsius / 10;
    wire [3:0] c_ones = celsius % 10;
    wire [3:0] f_tens = fahrenheit / 10;
    wire [3:0] f_ones = fahrenheit % 10;
    
    // ROMs de dígitos
    wire [6:0] digit_c_tens, digit_c_ones;
    wire [6:0] digit_f_tens, digit_f_ones;
    
    wire [2:0] char_row = row[2:0];
    
    digit_5x7_rom rom_c_tens(.digit(c_tens), .row(char_row), .pixel_row(digit_c_tens));
    digit_5x7_rom rom_c_ones(.digit(c_ones), .row(char_row), .pixel_row(digit_c_ones));
    digit_5x7_rom rom_f_tens(.digit(f_tens), .row(char_row), .pixel_row(digit_f_tens));
    digit_5x7_rom rom_f_ones(.digit(f_ones), .row(char_row), .pixel_row(digit_f_ones));
    
    // *** CORRECCIÓN: Posiciones más simples y centradas ***
    localparam TEXT_START_ROW = 8;   // Empezar en fila 8
    localparam TEXT_END_ROW = 15;    // 7 filas (8-14)
    
    // Posiciones horizontales más juntas
    localparam C_TENS_COL = 16;  // Decenas Celsius
    localparam C_ONES_COL = 22;  // Unidades Celsius
    localparam C_SYMBOL_COL = 28; // Símbolo °
    localparam F_TENS_COL = 32;  // Decenas Fahrenheit
    localparam F_ONES_COL = 38;  // Unidades Fahrenheit
    
    // Colores más brillantes
    localparam [23:0] COLOR_CELSIUS = 24'hFF0000;    // Rojo
    localparam [23:0] COLOR_FAHRENHEIT = 24'h00FF00; // Verde
    localparam [23:0] COLOR_BLACK = 24'h000000;
    
    wire in_text_row = (row >= TEXT_START_ROW) && (row < TEXT_END_ROW);
    wire [2:0] font_row = row - TEXT_START_ROW;
    
    always @(*) begin
        pixel_data = COLOR_BLACK;
        
        if (in_text_row && font_row < 7) begin
            // Mostrar decenas Celsius
            if (col >= C_TENS_COL && col < (C_TENS_COL + 5)) begin
                if (digit_c_tens[6 - (col - C_TENS_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar unidades Celsius
            else if (col >= C_ONES_COL && col < (C_ONES_COL + 5)) begin
                if (digit_c_ones[6 - (col - C_ONES_COL)])
                    pixel_data = COLOR_CELSIUS;
            end
            // Símbolo grado
            else if (col >= C_SYMBOL_COL && col < (C_SYMBOL_COL + 2)) begin
                if (font_row <= 2)
                    pixel_data = COLOR_CELSIUS;
            end
            // Mostrar decenas Fahrenheit
            else if (col >= F_TENS_COL && col < (F_TENS_COL + 5)) begin
                if (digit_f_tens[6 - (col - F_TENS_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
            // Mostrar unidades Fahrenheit
            else if (col >= F_ONES_COL && col < (F_ONES_COL + 5)) begin
                if (digit_f_ones[6 - (col - F_ONES_COL)])
                    pixel_data = COLOR_FAHRENHEIT;
            end
        end
    end
    
    // DEBUG: Imprimir cuando se genere un píxel no negro
    `ifdef SIMULATION
    always @(*) begin
        if (pixel_data != COLOR_BLACK) begin
            $display("[PIXEL_GEN] Row=%d Col=%d -> Color=%h (C=%d°C F=%d°F)", 
                     row, col, pixel_data, celsius, fahrenheit);
        end
    end
    `endif

endmodule