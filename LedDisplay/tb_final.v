`timescale 1ns / 1ps
`define SIMULATION

module tb_final;

    reg clk, rst;
    wire I2C_SDA, I2C_SCL;
    wire LP_CLK, LATCH, NOE;
    wire [4:0] ROW;
    wire [2:0] RGB0, RGB1;
    
    integer frame_count = 0;
    integer pixel_count = 0;
    integer row_8_count = 0;
    
    initial begin
        clk = 0;
        forever #20 clk = ~clk;
    end
    
    pullup(I2C_SDA);
    pullup(I2C_SCL);
    
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
    
   
    i2c_slave_lm75_model sensor(
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );
    
    
    always @(posedge clk) begin
        if (!NOE && (RGB0 != 3'b000 || RGB1 != 3'b000)) begin
            pixel_count = pixel_count + 1;
            if (pixel_count < 20) begin
                $display("[PIXEL] t=%0t Row=%d Col=%d RGB0=%b RGB1=%b", 
                         $time, ROW, dut.matrix.COL, RGB0, RGB1);
            end
        end
        
        if (!NOE && ROW == 8 && (RGB0 != 3'b000 || RGB1 != 3'b000)) begin
            row_8_count = row_8_count + 1;
        end
    end
    
    reg [4:0] last_row = 31;
    always @(posedge clk) begin
        if (ROW == 0 && last_row != 0) begin
            frame_count = frame_count + 1;
            $display("[Frame %0d] Píxeles: %0d (Fila8: %0d)", 
                     frame_count, pixel_count, row_8_count);
            row_8_count = 0;
        end
        last_row = ROW;
    end
    
    initial begin
        forever begin
            #2_000_000;
            if ($time > 1_000_000) begin
                $display("\n[%0tms] DEBUG:", $time/1000000);
                $display("  sys_rst=%b temp_c=%d temp_f=%d", 
                         dut.sys_rst, dut.temp_celsius, dut.temp_fahrenheit);
                $display("  FSM=%h Row=%d Col=%d", 
                         dut.matrix.ctrl0.state, ROW, dut.matrix.COL);
                $display("  pixel_data=%h RGB0=%b RGB1=%b NOE=%b",
                         dut.matrix.pixel_data, RGB0, RGB1, NOE);
            end
        end
    end
    
    
    initial begin
        $display("TEST TEMPERATURA LED MATRIX");
        
        $dumpfile("final_test.vcd");
        $dumpvars(0, tb_final);
        
        rst = 0;
        #200;
        rst = 1;
        #1000;
        
        $display("[INFO] Sistema iniciado");
        
        wait(dut.temp_celsius != 0);
        #10000;
        
        $display("TEMPERATURA LEÍDA ");
        $display("Celsius:    %2d°C ", dut.temp_celsius);
        $display("Fahrenheit: %2d°F ", dut.temp_fahrenheit);
        
        
        $display("\n[TEST] Probando pixel_generator directamente:");
        $display("  Dirección {8,16} (fila 8, col 16) debería ser ROJO");
        
        wait(frame_count >= 5);
        #500000;
        
        $display("RESULTADOS ");
        $display("Frames:  %2d", frame_count);
        $display("Píxeles: %5d", pixel_count);
        
        if (pixel_count > 10) begin
            $display("Estado: EXITOSO");
        end else begin
            $display("Estado: FALLO");
            $display("POSIBLE PROBLEMA:");
            $display("- pixel_generator devuelve negro ");
            $display("- Revisar condiciones in_text_row ");
        end
        
        
        $finish;
    end
    
    initial begin
        #30_000_000;
        $display("\n TIMEOUT");
        $display("Píxeles detectados: %0d", pixel_count);
        $finish;
    end

endmodule