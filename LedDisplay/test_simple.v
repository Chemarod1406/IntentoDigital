`timescale 1ns / 1ps
module test_simple(
    input clk,
    input rst,           // Botón con PULLUP (normalmente 1, presionado = 0)
    inout I2C_SDA,
    output I2C_SCL,
    output reg LP_CLK,
    output reg LATCH,
    output reg NOE,
    output reg [4:0] ROW,
    output reg [2:0] RGB0,
    output reg [2:0] RGB1
);

    // =========================================================================
    // RESET AUTOMÁTICO + SINCRONIZACIÓN
    // =========================================================================
    reg [2:0] rst_sync = 3'b111;
    always @(posedge clk) begin
        rst_sync <= {rst_sync[1:0], rst};
    end
    wire rst_clean = rst_sync[2];
    
    reg [20:0] por_counter = 0;
    reg por_reset = 1;
    
    always @(posedge clk) begin
        if (por_counter < 21'd1_000_000) begin
            por_counter <= por_counter + 1;
            por_reset <= 1;
        end else begin
            por_reset <= 0;
        end
    end
    
    wire sys_rst = por_reset | ~rst_clean;

    // =========================================================================
    // MÁQUINA DE ESTADOS PARA HUB75
    // =========================================================================
    reg [23:0] counter = 0;
    reg [5:0] col = 0;
    reg [2:0] state = 0;
    
    // Divisor de reloj para clock más lento
    reg [3:0] clk_div = 0;
    reg clk_slow = 0;
    
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
        if (clk_div == 0)
            clk_slow <= ~clk_slow;
    end
    
    always @(posedge clk_slow) begin
        if (sys_rst) begin
            state <= 0;
            ROW <= 0;
            col <= 0;
            counter <= 0;
            LP_CLK <= 0;
            LATCH <= 0;
            NOE <= 1;
            RGB0 <= 0;
            RGB1 <= 0;
        end else begin
            case(state)
                0: begin  // ESTADO: Enviar 64 píxeles
                    LATCH <= 0;
                    NOE <= 1;              // Mantener apagado mientras cargamos
                    LP_CLK <= ~LP_CLK;     // Toggle clock
                    
                    // Patrón: Mitad superior roja, mitad inferior azul
                    RGB0 <= 3'b100;        // Rojo
                    RGB1 <= 3'b001;        // Azul
                    
                    if (LP_CLK == 1) begin  // Contar solo en flanco de subida
                        col <= col + 1;
                        if (col == 63) begin
                            col <= 0;
                            state <= 1;
                            counter <= 0;
                        end
                    end
                end
                
                1: begin  // ESTADO: Latch (capturar datos)
                    LP_CLK <= 0;
                    RGB0 <= 0;
                    RGB1 <= 0;
                    LATCH <= 1;
                    NOE <= 1;
                    
                    if (counter == 10) begin  // Pulso de latch corto
                        counter <= 0;
                        state <= 2;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                2: begin  // ESTADO: Display ON (mostrar LEDs)
                    LATCH <= 0;
                    NOE <= 0;  // ¡Activar salida! (activo bajo)
                    
                    // Mantener la fila encendida por más tiempo (sin parpadeo)
                    if (counter == 24'd5000) begin  // ~200us por fila
                        counter <= 0;
                        state <= 3;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                3: begin  // ESTADO: Cambiar de fila
                    NOE <= 1;  // Apagar antes de cambiar fila
                    ROW <= ROW + 1;
                    state <= 0;
                end
                
                default: state <= 0;
            endcase
        end
    end

endmodule