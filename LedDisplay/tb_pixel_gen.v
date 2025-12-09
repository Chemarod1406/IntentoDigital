`timescale 1ns / 1ps
module tb_pixel_gen;

    reg [7:0] celsius;
    reg [7:0] fahrenheit;
    reg [10:0] pixel_addr;
    wire [23:0] pixel_data;
    
    temp_pixel_generator uut(
        .celsius(celsius),
        .fahrenheit(fahrenheit),
        .pixel_addr(pixel_addr),
        .pixel_data(pixel_data)
    );
    
    integer row, col;
    integer pixel_count = 0;
    
    initial begin
        $display("\n=== TEST DIRECTO PIXEL GENERATOR ===\n");
        
      
        celsius = 8'd30;
        fahrenheit = 8'd86;
        
        $display("Temperatura: %d C, %d F", celsius, fahrenheit);
        $display("Digitos C: %d%d", celsius/10, celsius%10);
        $display("Digitos F: %d%d", fahrenheit/10, fahrenheit%10);
        $display("Area texto: filas 12-18, cols C:8-24, F:34-50\n");
        
        
        for (row = 0; row < 32; row = row + 1) begin
            for (col = 0; col < 64; col = col + 1) begin
                pixel_addr = {row[4:0], col[5:0]};
                #10;
                
                if (pixel_data != 24'h000000) begin
                    pixel_count = pixel_count + 1;
                    if (pixel_count <= 30)
                        $display("PIXEL! row=%2d col=%2d data=%h", row, col, pixel_data);
                end
            end
        end
        
        $display("\n=== RESULTADO ===");
        $display("Total pixeles no negros: %d", pixel_count);
        
        if (pixel_count > 10) begin
            $display("EXITO!");
        end else begin
            $display("FALLO - Muy pocos pixeles");
            
            
            $display("\n=== DEBUG POSICIONES ===");
            

            pixel_addr = {5'd12, 6'd8};
            #10;
            $display("Fila 12, Col 8: data=%h (deberia ser rojo si digito 3 tiene pixel ahi)", pixel_data);
            
            pixel_addr = {5'd12, 6'd9};
            #10;
            $display("Fila 12, Col 9: data=%h", pixel_data);
            
            pixel_addr = {5'd12, 6'd10};
            #10;
            $display("Fila 12, Col 10: data=%h", pixel_data);
            
            
            $display("\n=== DIGITO 3 (decenas de 30) ===");
            $display("ROM deberia dar: row0=0011100, row1=0100010...");
        end
        
        $finish;
    end

endmodule
