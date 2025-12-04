`timescale 1ns / 1ps

module tb_temp_display;

    reg clk;
    reg rst;
    wire I2C_SDA;
    wire I2C_SCL;
    wire LP_CLK, LATCH, NOE;
    wire [4:0] ROW;
    wire [2:0] RGB0, RGB1;

    // Contadores para diagnóstico
    integer pixel_count = 0;
    integer frame_count = 0;
    integer red_pixels = 0;
    integer blue_pixels = 0;
    
    // 1. GENERACIÓN DE RELOJ (25MHz)
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 40ns periodo = 25MHz
    end

    // 2. RESISTENCIAS PULL-UP (CRUCIAL PARA I2C)
    pullup(I2C_SDA);
    pullup(I2C_SCL);

    // 3. INSTANCIA DEL DUT
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

    // 4. MODELO DEL SENSOR I2C
    i2c_slave_lm75_model slave(
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );

    // 5. MONITOR DE PÍXELES ENCENDIDOS
    always @(posedge clk) begin
        if (!NOE && (RGB0 !== 3'bxxx && RGB1 !== 3'bxxx)) begin
            if (RGB0 != 3'b000) begin
                pixel_count = pixel_count + 1;
                // Detectar colores
                if (RGB0[2]) red_pixels = red_pixels + 1;    // R0 = bit 2
                if (RGB0[0]) blue_pixels = blue_pixels + 1;  // B0 = bit 0
            end
            if (RGB1 != 3'b000) begin
                pixel_count = pixel_count + 1;
                if (RGB1[2]) red_pixels = red_pixels + 1;
                if (RGB1[0]) blue_pixels = blue_pixels + 1;
            end
        end
    end
    
    // 6. DETECTOR DE FRAMES COMPLETOS
    reg [4:0] last_row = 5'b11111;
    always @(posedge clk) begin
        if (ROW == 0 && last_row != 0) begin
            frame_count = frame_count + 1;
            if (frame_count > 0) begin
                $display("[Frame %0d] Píxeles: %0d (Rojos: %0d, Azules: %0d)", 
                         frame_count, pixel_count, red_pixels, blue_pixels);
            end
            pixel_count = 0;
            red_pixels = 0;
            blue_pixels = 0;
        end
        last_row = ROW;
    end

    // 7. MONITOR BÁSICO DE SEÑALES
    always @(posedge clk) begin
        if ($time > 100000000 && $time < 100010000) begin  // Solo primeros 10us después de init
            $display("[%t] ROW=%d NOE=%b LATCH=%b RGB0=%b RGB1=%b", 
                     $time, ROW, NOE, LATCH, RGB0, RGB1);
        end
    end

    // 8. ESTÍMULOS PRINCIPALES
    initial begin
        $display("\n========================================");
        $display("   TEST DE DISPLAY DE TEMPERATURA");
        $display("========================================\n");
        
        $dumpfile("temp_display_dump.vcd");
        $dumpvars(0, tb_temp_display);
        
        // Reset inicial
        rst = 1;
        #200;
        rst = 0;
        
        $display("[INFO] Sistema iniciado, esperando lectura I2C...");
        
        // Esperar a que termine el Power-On Reset interno
        wait(dut.auto_rst == 0);
        #1000;
        $display("[INFO] Power-On Reset completado");
        
        // Esperar lectura de temperatura
        wait(dut.c_data != 0);
        #5000;
        
        $display("\n========================================");
        $display("   TEMPERATURA LEÍDA DEL SENSOR");
        $display("========================================");
        $display("  Celsius:    %0d°C", dut.c_data);
        $display("  Fahrenheit: %0d°F", dut.f_data);
        $display("========================================\n");
        
        // DEBUG: Verificar señales críticas
        $display("[DEBUG] sys_rst=%b init=%b", dut.sys_rst, dut.matrix_ctrl.init);
        $display("[DEBUG] clk_matrix=%b", dut.matrix_ctrl.clk_matrix);
        
        // Esperar que se generen varios frames
        $display("[INFO] Esperando frames de video...\n");
        
        // Esperar más tiempo para ver actividad
        #50_000_000;  // 50ms adicionales
        
        if (frame_count == 0) begin
            $display("\n⚠️  ADVERTENCIA: No se detectaron frames después de 50ms");
            $display("[DEBUG] Última fila vista: %d", ROW);
            $display("[DEBUG] NOE=%b LATCH=%b", NOE, LATCH);
        end
        
        wait(frame_count >= 3);
        #100000;  // 100us más
        
        // RESULTADOS FINALES
        $display("\n========================================");
        $display("   RESULTADOS DEL TEST");
        $display("========================================");
        $display("Frames generados: %0d", frame_count);
        $display("Píxeles totales:  %0d", pixel_count);
        $display("Píxeles rojos:    %0d (Celsius)", red_pixels);
        $display("Píxeles azules:   %0d (Fahrenheit)", blue_pixels);
        
        // Verificaciones
        if (dut.c_data == 0) begin
            $display("\n❌ ERROR: Temperatura no leída del sensor");
        end else begin
            $display("\n✅ Temperatura leída correctamente");
        end
        
        if (frame_count == 0) begin
            $display("❌ ERROR: No se generaron frames");
        end else begin
            $display("✅ Frames generados correctamente");
        end
        
        if (pixel_count == 0) begin
            $display("❌ ERROR: No se encendieron píxeles");
        end else begin
            $display("✅ Píxeles visibles en pantalla");
        end
        
        if (red_pixels > 0 && blue_pixels > 0) begin
            $display("✅ Ambos colores (Celsius y Fahrenheit) visibles");
        end else begin
            $display("⚠️  ADVERTENCIA: Solo se ve un color");
        end
        
        $display("========================================\n");
        $finish;
    end
    
    // 9. TIMEOUT DE SEGURIDAD (500ms)
    initial begin
        #500_000_000;
        $display("\n⏱️  TIMEOUT: Test excedió 500ms");
        $display("Frames completados: %0d", frame_count);
        $finish;
    end

endmodule