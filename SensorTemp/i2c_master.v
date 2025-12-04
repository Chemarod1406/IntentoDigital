`timescale 1ns / 1ps
// I2C Master CORREGIDO - Muestreo correcto en flanco positivo de SCL
module i2c_master(
    input clk_200KHz,
    inout SDA,
    output [7:0] temp_data,
    output SCL
    );
    
    // *** GENERATE 10kHz SCL clock from 200kHz ***
    reg [3:0] counter = 4'b0;
    reg clk_reg = 1'b1; 
    assign SCL = clk_reg;
    
    // Signals
    parameter [7:0] sensor_address_plus_read = 8'b1001_0001;
    
    reg [7:0] tMSB = 8'h00;
    reg [7:0] tLSB = 8'h00;
    reg o_bit = 1'b1;
    reg sda_oe = 1'b0;
    reg [11:0] count = 12'b0;
    reg [7:0] temp_data_reg = 8'h00;
    
    // CRITICAL: Sample SDA only when SCL is high
    reg sda_sample = 1'b1;
    
    assign temp_data = temp_data_reg;

    // State Declarations
    localparam [4:0] POWER_UP   = 5'h00,
                     START      = 5'h01,
                     SEND_ADDR6 = 5'h02,
                     SEND_ADDR5 = 5'h03,
                     SEND_ADDR4 = 5'h04,
                     SEND_ADDR3 = 5'h05,
                     SEND_ADDR2 = 5'h06,
                     SEND_ADDR1 = 5'h07,
                     SEND_ADDR0 = 5'h08,
                     SEND_RW    = 5'h09,
                     REC_ACK    = 5'h0A,
                     REC_MSB7   = 5'h0B,
                     REC_MSB6   = 5'h0C,
                     REC_MSB5   = 5'h0D,
                     REC_MSB4   = 5'h0E,
                     REC_MSB3   = 5'h0F,
                     REC_MSB2   = 5'h10,
                     REC_MSB1   = 5'h11,
                     REC_MSB0   = 5'h12,
                     SEND_ACK   = 5'h13,
                     REC_LSB7   = 5'h14,
                     REC_LSB6   = 5'h15,
                     REC_LSB5   = 5'h16,
                     REC_LSB4   = 5'h17,
                     REC_LSB3   = 5'h18,
                     REC_LSB2   = 5'h19,
                     REC_LSB1   = 5'h1A,
                     REC_LSB0   = 5'h1B,
                     NACK       = 5'h1C;
      
    reg [4:0] state_reg = POWER_UP;
    
    // Sample SDA when SCL goes high (middle of clock high period)
    always @(posedge clk_200KHz) begin
        // Sample at count values where SCL should be stable high
        // SCL toggles every 10 counts, so sample at +5 offset
        if (counter == 4'd5 && clk_reg == 1'b1)
            sda_sample <= SDA;
    end
                        
    always @(posedge clk_200KHz) begin
        // Clock generator
        if(counter == 9) begin
            counter <= 4'b0;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;

        count <= count + 1;
        
        // State Machine Logic
        case(state_reg)
            POWER_UP: begin
                sda_oe <= 1'b1;
                o_bit <= 1'b1;
                if(count == 12'd1999)
                    state_reg <= START;
            end
            
            START: begin
                sda_oe <= 1'b1;
                if(count == 12'd2004)
                    o_bit <= 1'b0;  // START condition
                if(count == 12'd2013)
                    state_reg <= SEND_ADDR6;
            end
            
            SEND_ADDR6: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[7];
                if(count == 12'd2033)
                    state_reg <= SEND_ADDR5;
            end
            
            SEND_ADDR5: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[6];
                if(count == 12'd2053)
                    state_reg <= SEND_ADDR4;
            end
            
            SEND_ADDR4: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[5];
                if(count == 12'd2073)
                    state_reg <= SEND_ADDR3;
            end
            
            SEND_ADDR3: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[4];
                if(count == 12'd2093)
                    state_reg <= SEND_ADDR2;
            end
            
            SEND_ADDR2: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[3];
                if(count == 12'd2113)
                    state_reg <= SEND_ADDR1;
            end
            
            SEND_ADDR1: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[2];
                if(count == 12'd2133)
                    state_reg <= SEND_ADDR0;
            end
            
            SEND_ADDR0: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[1];
                if(count == 12'd2153)
                    state_reg <= SEND_RW;
            end
            
            SEND_RW: begin
                sda_oe <= 1'b1;
                o_bit <= sensor_address_plus_read[0];
                if(count == 12'd2169) begin
                    sda_oe <= 1'b0;  // Release for ACK
                    state_reg <= REC_ACK;
                end
            end
            
            REC_ACK: begin
                sda_oe <= 1'b0;
                if(count == 12'd2189)
                    state_reg <= REC_MSB7;
            end
            
            REC_MSB7: begin
                sda_oe <= 1'b0;
                if(count == 12'd2199)  // Sample in middle of bit
                    tMSB[7] <= sda_sample;
                if(count == 12'd2209)
                    state_reg <= REC_MSB6;
            end
            
            REC_MSB6: begin
                sda_oe <= 1'b0;
                if(count == 12'd2219)
                    tMSB[6] <= sda_sample;
                if(count == 12'd2229)
                    state_reg <= REC_MSB5;
            end
            
            REC_MSB5: begin
                sda_oe <= 1'b0;
                if(count == 12'd2239)
                    tMSB[5] <= sda_sample;
                if(count == 12'd2249)
                    state_reg <= REC_MSB4;
            end
            
            REC_MSB4: begin
                sda_oe <= 1'b0;
                if(count == 12'd2259)
                    tMSB[4] <= sda_sample;
                if(count == 12'd2269)
                    state_reg <= REC_MSB3;
            end
            
            REC_MSB3: begin
                sda_oe <= 1'b0;
                if(count == 12'd2279)
                    tMSB[3] <= sda_sample;
                if(count == 12'd2289)
                    state_reg <= REC_MSB2;
            end
            
            REC_MSB2: begin
                sda_oe <= 1'b0;
                if(count == 12'd2299)
                    tMSB[2] <= sda_sample;
                if(count == 12'd2309)
                    state_reg <= REC_MSB1;
            end
            
            REC_MSB1: begin
                sda_oe <= 1'b0;
                if(count == 12'd2319)
                    tMSB[1] <= sda_sample;
                if(count == 12'd2329)
                    state_reg <= REC_MSB0;
            end
            
            REC_MSB0: begin
                sda_oe <= 1'b0;
                if(count == 12'd2339)
                    tMSB[0] <= sda_sample;
                if(count == 12'd2349)
                    state_reg <= SEND_ACK;
            end
            
            SEND_ACK: begin
                sda_oe <= 1'b1;
                o_bit <= 1'b0;  // Send ACK
                if(count == 12'd2369) begin
                    sda_oe <= 1'b0;
                    state_reg <= REC_LSB7;
                end
            end
            
            REC_LSB7: begin
                sda_oe <= 1'b0;
                if(count == 12'd2379)
                    tLSB[7] <= sda_sample;
                if(count == 12'd2389)
                    state_reg <= REC_LSB6;
            end
            
            REC_LSB6: begin
                sda_oe <= 1'b0;
                if(count == 12'd2399)
                    tLSB[6] <= sda_sample;
                if(count == 12'd2409)
                    state_reg <= REC_LSB5;
            end
            
            REC_LSB5: begin
                sda_oe <= 1'b0;
                if(count == 12'd2419)
                    tLSB[5] <= sda_sample;
                if(count == 12'd2429)
                    state_reg <= REC_LSB4;
            end
            
            REC_LSB4: begin
                sda_oe <= 1'b0;
                if(count == 12'd2439)
                    tLSB[4] <= sda_sample;
                if(count == 12'd2449)
                    state_reg <= REC_LSB3;
            end
            
            REC_LSB3: begin
                sda_oe <= 1'b0;
                if(count == 12'd2459)
                    tLSB[3] <= sda_sample;
                if(count == 12'd2469)
                    state_reg <= REC_LSB2;
            end
            
            REC_LSB2: begin
                sda_oe <= 1'b0;
                if(count == 12'd2479)
                    tLSB[2] <= sda_sample;
                if(count == 12'd2489)
                    state_reg <= REC_LSB1;
            end
            
            REC_LSB1: begin
                sda_oe <= 1'b0;
                if(count == 12'd2499)
                    tLSB[1] <= sda_sample;
                if(count == 12'd2509)
                    state_reg <= REC_LSB0;
            end
            
            REC_LSB0: begin
                sda_oe <= 1'b0;
                if(count == 12'd2519)
                    tLSB[0] <= sda_sample;
                if(count == 12'd2529)
                    state_reg <= NACK;
            end
            
            NACK: begin
                sda_oe <= 1'b1;
                o_bit <= 1'b1;  // NACK
                if(count == 12'd2559) begin
                    count <= 12'd2000;
                    state_reg <= START;
                    temp_data_reg <= tMSB;  // Update output
                end
            end
        endcase
    end
    
    // SDA tri-state control
    assign SDA = sda_oe ? o_bit : 1'bz;
 
endmodule