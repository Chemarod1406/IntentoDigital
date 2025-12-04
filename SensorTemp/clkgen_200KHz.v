`timescale 1ns / 1ps
// Created by David J. Marion
// Date 7.19.2022
// 200kHz Generator for the Nexys A7 Temperature Sensor I2C Master
// MODIFICADO para CLOCK de 25MHz (Colorlight 5A-75B)
module clkgen_200KHz(
    input clk_25MHz, // <--- CAMBIO DE NOMBRE DEL PUERTO
    output clk_200KHz
    );
    
    // 25 x 10^6 / 200 x 10^3 / 2 = 62.5 <-- Usamos 62
    // La frecuencia real de salida es: 25MHz / (2 * (62 + 1)) = 198.4kHz
    reg [7:0] counter = 8'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk_25MHz) begin // <--- USO DEL PUERTO CORREGIDO
        if(counter == 8'd62) begin // CAMBIADO de 249 a 62
            counter <= 8'h00;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    assign clk_200KHz = clk_reg;
    
endmodule