`timescale 1ns / 1ps

module tb_top;
    reg  CLK100MHZ; 
    wire TMP_SDA; 
    wire TMP_SCL;
    wire [6:0] SEG;
    wire [7:0] AN;
    wire [15:0] LED;

    initial begin
        CLK100MHZ = 1'b0;
        forever #20 CLK100MHZ = ~CLK100MHZ; 
    end

    pullup(TMP_SDA);
    pullup(TMP_SCL);

    top dut (
        .CLK100MHZ(CLK100MHZ),
        .TMP_SDA(TMP_SDA),
        .TMP_SCL(TMP_SCL),
        .SEG(SEG),
        .AN(AN),
        .LED(LED)
    );
    
    i2c_slave_lm75_model slave (
        .SDA(TMP_SDA),
        .SCL(TMP_SCL)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
        
        $display("=== Iniciando Simulación ===");
        
        #40000000; 
        
        $display("Temp Celsius (Esperado 30): %d", dut.c_data);
        $display("Temp Fahrenheit (Esperado 86): %d", dut.f_data);
        
        if(dut.c_data === 8'h1E) 
            $display("SUCCESS: Lectura Correcta.");
        else 
            $display("FAIL: Lectura Incorrecta.");
            
        $finish;
    end
endmodule