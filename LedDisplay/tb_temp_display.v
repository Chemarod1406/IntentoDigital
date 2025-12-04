`timescale 1ns / 1ps

module tb_temp_display;

    reg clk;
    reg rst;
    wire I2C_SDA;
    wire I2C_SCL;
    wire LP_CLK, LATCH, NOE;
    wire [4:0] ROW;
    wire [2:0] RGB0, RGB1;

    // 1. GENERACIÓN DE RELOJ (25MHz)
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 40ns periodo = 25MHz
    end

    // 2. RESISTENCIAS PULL-UP (CRUCIAL PARA I2C)
    // Sin esto, la simulación lee 'Z' en lugar de '1' y falla.
    pullup(I2C_SDA);
    pullup(I2C_SCL);

    // 3. INSTANCIA DEL TOP MODULE
    temp_display_top dut(
        .clk(clk),
        .rst(rst),
        .I2C_SDA(I2C_SDA),
        .I2C_SCL(I2C_SCL),
        .LP_CLK(LP_CLK),
        .LATCH(LATCH),
        .NOE(NOE),
        .ROW(ROW),
        .RGB0(RGB0),
        .RGB1(RGB1)
    );

    // 4. MODELO DEL SENSOR I2C (Simula el LM75)
    i2c_slave_lm75_model slave(
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );

    // 5. ESTÍMULOS Y CONTROL
    initial begin
        $display("=== Iniciando test de display de temperatura ===");
        $dumpfile("temp_display_dump.vcd"); // Para ver ondas en GTKWave
        $dumpvars(0, tb_temp_display);
        
        // --- SECUENCIA DE RESET CORREGIDA ---
        rst = 1;      // Reset activado
        #100;
        rst = 0;      // Reset desactivado (El sistema empieza a funcionar)
        // Eliminada la línea "rst = 1" que volvía a apagar todo
        
        // Esperar tiempo suficiente para:
        // a) Que el i2c master inicialice (power up wait)
        // b) Que se transmita la temperatura
        // c) Que la pantalla empiece a barrer
        #60000000;  // 10ms (suficiente para ver actividad)
        
        $display("\nTemperatura leída interna (DUT):");
        $display("  Celsius: %d (Esperado: 25 o 30 segun modelo)", dut.c_data);
        $display("  Fahrenheit: %d", dut.f_data);
        
        $display("\nSeñales LED Matrix (Estado actual):");
        $display("  ROW: %b", ROW);
        $display("  RGB0: %b", RGB0);
        $display("  RGB1: %b", RGB1);
        
        if(dut.c_data == 0) 
            $display("ERROR: La temperatura sigue siendo 0. Revisa las pullups.");
        else
            $display("EXITO: Lectura de temperatura correcta.");

        $display("\n=== Test completado ===");
        $finish;
    end
    // --- MONITOR DE PÍXELES ENCENDIDOS ---
    // Esto imprimirá un mensaje cada vez que el controlador mande color a la pantalla
    always @(RGB0 or RGB1) begin
        if(RGB0 != 0 || RGB1 != 0) begin
            $display("time: %t | ¡PÍXEL ENCENDIDO! -> Row: %d, RGB0: %b, RGB1: %b", $time, ROW, RGB0, RGB1);
        end
    end
endmodule