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
        forever #20 clk = ~clk;
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
    
    // Monitor de píxeles con debug
    always @(posedge clk) begin
        if (!NOE && (RGB0 != 3'b000 || RGB1 != 3'b000)) begin
            pixel_count = pixel_count + 1;
            if (pixel_count < 5) begin  // Mostrar solo los primeros
                $display("[PIXEL] Row=%d RGB0=%b RGB1=%b", ROW, RGB0, RGB1);
            end
        end
    end
    
    // Debug del generador de píxeles
    initial begin
        #15_000_000;  // Después de 15ms
        $display("\n[DEBUG] Estado interno:");
        $display("  pixel_data=%h", dut.matrix.pixel_data);
        $display("  RGB0=%b RGB1=%b (después del MUX)", RGB0, RGB1);
        $display("  index=%b", dut.matrix.index);
        $display("  NOE=%b (0=encendido, 1=apagado)", NOE);
        $display("  tmp_noe=%b tmp_latch=%b", dut.matrix.tmp_noe, dut.matrix.tmp_latch);
        $display("  Estado FSM ctrl: state=%h", dut.matrix.ctrl0.state);
    end
    
    // Detector de frames
    reg [4:0] last_row = 31;
    always @(posedge clk) begin
        if (ROW == 0 && last_row != 0) begin
            frame_count = frame_count + 1;
            $display("[Frame %0d] - Píxeles: %0d", frame_count, pixel_count);
            pixel_count = 0;
        end
        last_row = ROW;
    end
    
    // Test
    initial begin
        $display("\n=== TEST TEMPERATURA CON ESTRUCTURA DEL PROFESOR ===\n");
        $dumpfile("final_test.vcd");
        $dumpvars(0, tb_final);
        
        rst = 0;
        #100;
        rst = 1;
        #100;
        rst = 0;
        
        $display("[INFO] Esperando temperatura...");
        wait(dut.temp_celsius != 0);
        #1000;
        
        $display("\n=== TEMPERATURA ===");
        $display("  Celsius:    %0d°C", dut.temp_celsius);
        $display("  Fahrenheit: %0d°F", dut.temp_fahrenheit);
        $display("===================\n");
        
        $display("[INFO] Esperando frames...");
        wait(frame_count >= 3);
        #10000;
        
        $display("\n=== RESULTADOS ===");
        $display("Frames: %0d", frame_count);
        if (frame_count > 0)
            $display("✅ Sistema funcionando");
        else
            $display("❌ No hay frames");
        $display("==================\n");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #50_000_000;  // 50ms
        $display("\n⏱️ TIMEOUT");
        $finish;
    end

endmodule