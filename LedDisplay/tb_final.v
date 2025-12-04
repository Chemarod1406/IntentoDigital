`timescale 1ns / 1ps

module tb_final;

    reg clk, rst;
    wire I2C_SDA, I2C_SCL;
    wire LP_CLK, LATCH, NOE;
    wire [4:0] ROW;
    wire [2:0] RGB0, RGB1;
    
    integer frame_count = 0;
    integer pixel_count = 0;
    
    // Clock 25MHz
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 40ns = 25MHz
    end
    
    // Pull-ups I2C
    pullup(I2C_SDA);
    pullup(I2C_SCL);
    
    // DUT
    temp_display_top_final dut(
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
    
    // Sensor I2C
    i2c_slave_lm75_model sensor(
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );
    
    // Monitor de píxeles
    always @(posedge clk) begin
        if (!NOE && (RGB0 != 3'b000 || RGB1 != 3'b000)) begin
            pixel_count = pixel_count + 1;
            if (pixel_count < 10) begin
                $display("[t=%0t] PIXEL ENCENDIDO: Row=%d RGB0=%b RGB1=%b", 
                         $time, ROW, RGB0, RGB1);
            end
        end
    end
    
    // Detector de frames
    reg [4:0] last_row = 31;
    always @(posedge clk) begin
        if (ROW == 0 && last_row != 0) begin
            frame_count = frame_count + 1;
            $display("[Frame %0d completado] Píxeles vistos: %0d", frame_count, pixel_count);
        end
        last_row = ROW;
    end
    
    // Debug cada 1ms
    initial begin
        forever begin
            #1_000_000;  // 1ms
            if ($time > 1_000_000) begin  // Después de 1ms
                $display("[t=%0tms] sys_rst=%b rst_in=%b FSM=%h clk1=%b init=%b", 
                         $time/1000000, dut.sys_rst, rst,
                         dut.matrix.ctrl0.state, dut.matrix.clk1, dut.matrix.ctrl0.init);
                
                if (dut.matrix.ctrl0.state != 0) begin
                    $display("  → FSM en estado %h! delay=%d count=%d ZD=%b", 
                             dut.matrix.ctrl0.state,
                             dut.matrix.delay, dut.matrix.count_delay, dut.matrix.w_ZD);
                end
            end
        end
    end
    
    // Test principal
    initial begin
        $display("\n╔══════════════════════════════════════╗");
        $display("║ TEST TEMPERATURA LED MATRIX          ║");
        $display("╚══════════════════════════════════════╝\n");
        
        $dumpfile("final_test.vcd");
        $dumpvars(0, tb_final);
        
        // Reset simple
        rst = 0;  // Reset activo
        #200;
        rst = 1;  // Liberar reset
        #1000;
        
        $display("[INFO] Reset liberado, sistema iniciando...");
        
        // Esperar temperatura
        $display("[INFO] Esperando lectura de temperatura...");
        wait(dut.temp_celsius != 0);
        #10000;
        
        $display("\n╔══════════════════════════════════════╗");
        $display("║ TEMPERATURA LEÍDA                    ║");
        $display("╠══════════════════════════════════════╣");
        $display("║  Celsius:    %2d°C                   ║", dut.temp_celsius);
        $display("║  Fahrenheit: %2d°F                   ║", dut.temp_fahrenheit);
        $display("╚══════════════════════════════════════╝\n");
        
        // Esperar varios frames
        $display("[INFO] Esperando frames de video...");
        wait(frame_count >= 3);
        #100000;
        
        $display("\n╔══════════════════════════════════════╗");
        $display("║ RESULTADOS                           ║");
        $display("╠══════════════════════════════════════╣");
        $display("║  Frames completos: %2d                ║", frame_count);
        $display("║  Píxeles totales:  %5d             ║", pixel_count);
        
        if (frame_count >= 3 && pixel_count > 100) begin
            $display("║  Estado: ✅ EXITOSO                  ║");
        end else begin
            $display("║  Estado: ❌ FALLO                    ║");
            $display("║  - Frames esperados: >= 3            ║");
            $display("║  - Píxeles esperados: > 100          ║");
        end
        
        $display("╚══════════════════════════════════════╝\n");
        
        $finish;
    end
    
    // Timeout de seguridad
    initial begin
        #50_000_000;  // 50ms
        $display("\n⏱️ TIMEOUT - Test excedió 50ms");
        $display("Frames: %0d, Píxeles: %0d", frame_count, pixel_count);
        $finish;
    end

endmodule