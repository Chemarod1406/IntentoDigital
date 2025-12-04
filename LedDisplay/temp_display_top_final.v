`timescale 1ns / 1ps

module temp_display_top_final(
    input         clk,
    input         rst,      // Botón con PULLUP (1=normal, 0=presionado)
    inout         I2C_SDA,
    output        I2C_SCL,
    output        LP_CLK,
    output        LATCH,
    output        NOE,
    output [4:0]  ROW,
    output [2:0]  RGB0,
    output [2:0]  RGB1
);

    // =========================================================================
    // RESET SIMPLIFICADO - INVERTIDO CORRECTAMENTE
    // =========================================================================
    wire sys_rst = ~rst;  // rst=1 → sys_rst=0 (no reset)
                          // rst=0 → sys_rst=1 (reset activo)

    // =========================================================================
    // INTERFAZ SENSOR I2C
    // =========================================================================
    wire w_200KHz;
    wire [7:0] temp_celsius;
    wire [7:0] temp_fahrenheit;
    
    i2c_master i2c_sensor(
        .clk_200KHz(w_200KHz),
        .temp_data(temp_celsius),
        .SDA(I2C_SDA),
        .SCL(I2C_SCL)
    );
    
    clkgen_200KHz clkgen(
        .clk_25MHz(clk),
        .clk_200KHz(w_200KHz)
    );
    
    temp_converter converter(
        .c(temp_celsius),
        .f(temp_fahrenheit)
    );

    // =========================================================================
    // CONTROLADOR MATRIZ LED
    // =========================================================================
    led_temp_simple matrix(
        .clk(clk),
        .rst(sys_rst),
        .temp_c(temp_celsius),
        .temp_f(temp_fahrenheit),
        .LP_CLK(LP_CLK),
        .LATCH(LATCH),
        .NOE(NOE),
        .ROW(ROW),
        .RGB0(RGB0),
        .RGB1(RGB1)
    );

endmodule