`timescale 1ns / 1ps
module i2c_slave_lm75_model(
    inout SDA,
    input SCL
);
    reg [7:0] MSB_DATA = 8'h1E; 
    reg [7:0] LSB_DATA = 8'h00; 

    localparam S_IDLE=0, S_ADDR=1, S_ACK=2, S_TX_MSB=3, S_ACK_M=4, S_TX_LSB=5, S_NACK=6;
    reg [3:0] state = S_IDLE;
    reg [2:0] bit_cnt = 0;
    reg sda_out = 1;
    reg sda_en = 0;

    assign SDA = sda_en ? sda_out : 1'bz;

    always @(negedge SDA) if(SCL) begin state <= S_ADDR; bit_cnt<=7; sda_en<=0; end
    always @(posedge SDA) if(SCL) begin state <= S_IDLE; sda_en<=0; end

    always @(negedge SCL) begin
        #10000; 
        case(state)
            S_ADDR: if(bit_cnt==0) begin state<=S_ACK; sda_en<=1; sda_out<=0; end else begin bit_cnt<=bit_cnt-1; sda_en<=0; end
            S_ACK:  begin state<=S_TX_MSB; bit_cnt<=7; sda_en<=1; sda_out<=MSB_DATA[7]; end
            S_TX_MSB: if(bit_cnt==0) begin state<=S_ACK_M; sda_en<=0; end else begin bit_cnt<=bit_cnt-1; sda_en<=1; sda_out<=MSB_DATA[bit_cnt-1]; end
            S_ACK_M: begin state<=S_TX_LSB; bit_cnt<=7; sda_en<=1; sda_out<=LSB_DATA[7]; end
            S_TX_LSB: if(bit_cnt==0) begin state<=S_NACK; sda_en<=0; end else begin bit_cnt<=bit_cnt-1; sda_en<=1; sda_out<=LSB_DATA[bit_cnt-1]; end
            S_NACK: begin state<=S_IDLE; sda_en<=0; end
        endcase
    end
endmodule