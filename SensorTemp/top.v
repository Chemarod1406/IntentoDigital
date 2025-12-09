`timescale 1ns / 1ps
module top(
    input         CLK100MHZ,        
    inout         TMP_SDA,          
    output        TMP_SCL,          
    output [6:0]  SEG,              
    output [7:0]  AN,               
    output [15:0] LED               
    );
    
    wire w_200KHz;                  
    wire [7:0] c_data;              
    wire [7:0] f_data;              

    i2c_master i2cmaster(
        .clk_200KHz(w_200KHz),
        .temp_data(c_data),
        .SDA(TMP_SDA),
        .SCL(TMP_SCL)
    );
    
    // Instantiate 200kHz clock generator
    clkgen_200KHz clkgen(
        .clk_25MHz(CLK100MHZ), 
        .clk_200KHz(w_200KHz)
    );
    
    seg7c segcontrol(
        .clk_25MHz(CLK100MHZ), 
        .c_data(c_data),
        .f_data(f_data),
        .SEG(SEG),
        .AN(AN)
    );
    
    temp_converter tempconv(
        .c(c_data),
        .f(f_data)
    );
    
    // Set LED values for temperature data
    assign LED[15:8] = f_data;
    assign LED[7:0]  = c_data;

endmodule