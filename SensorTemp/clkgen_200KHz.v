`timescale 1ns / 1ps

module clkgen_200KHz(
    input clk_25MHz,
    output clk_200KHz
    );
    
    reg [7:0] counter = 8'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk_25MHz) begin 
        if(counter == 8'd62) begin 
            counter <= 8'h00;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    assign clk_200KHz = clk_reg;
    
endmodule