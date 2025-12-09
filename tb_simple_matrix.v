`timescale 1ns / 1ps

module tb_simple_matrix;

    reg clk;
    reg rst;
    wire LP_CLK, LATCH, NOE;
    wire [4:0] ROW;
    wire [2:0] RGB0, RGB1;
    
    integer pixel_count = 0;
    integer frame_count = 0;
    
    initial begin
        clk = 0;
        forever #20 clk = ~clk;
    end
    
    led_panel_temp_display dut(
        .clk(clk),
        .rst(rst),
        .init(1'b1),        
        .c_val(8'd25),      
        .f_val(8'd77),      
        .LP_CLK(LP_CLK),
        .LATCH(LATCH),
        .NOE(NOE),
        .ROW(ROW),
        .RGB0(RGB0),
        .RGB1(RGB1)
    );
    
   
    always @(posedge clk) begin
        if (!NOE && (RGB0 != 3'b000 || RGB1 != 3'b000)) begin
            pixel_count = pixel_count + 1;
            if (pixel_count < 20) begin
                $display("[%t] ROW=%02d RGB0=%b RGB1=%b", $time, ROW, RGB0, RGB1);
            end
        end
    end
    
   
    reg [4:0] last_row = 5'b11111;
    always @(posedge clk) begin
        if (ROW == 0 && last_row == 31) begin
            frame_count = frame_count + 1;
            $display("\n[Frame %0d completado] Píxeles: %0d", frame_count, pixel_count);
            pixel_count = 0;
        end
        last_row = ROW;
    end
    
   
    initial begin
        $dumpfile("matrix_test.vcd");
        $dumpvars(0, tb_simple_matrix);
        
        $display("TEST DE MATRIZ LED 64x64");
        
        rst = 1;
        #200;
        rst = 0;
        
        $display("Sistema iniciado, esperando frames...\n");
        
       
        wait(frame_count >= 3);
        #10000;
        
        $display("RESULTADOS");
        $display("Frames: %0d", frame_count);
        $display("Píxeles por frame: ~%0d", pixel_count);
        
        if (frame_count > 0 && pixel_count > 0) begin
            $display("\nTEST EXITOSO");
        end else begin
            $display("\nTEST FALLIDO");
        end
        
        $finish;
    end
    
    initial begin
        #100_000_000;  
        $display("\nTIMEOUT");
        $finish;
    end

endmodule