`timescale 1ns / 1ps
module digit_5x7_rom(
    input [3:0] digit,      
    input [2:0] row,        
    output reg [6:0] pixel_row  

    always @(*) begin
        case (digit)
            4'd0: begin  
                case (row)
                    3'd0: pixel_row = 7'b0011100;
                    3'd1: pixel_row = 7'b0100010;
                    3'd2: pixel_row = 7'b0100010;
                    3'd3: pixel_row = 7'b0100010;
                    3'd4: pixel_row = 7'b0100010;
                    3'd5: pixel_row = 7'b0100010;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd1: begin  
                case (row)
                    3'd0: pixel_row = 7'b0001000;
                    3'd1: pixel_row = 7'b0011000;
                    3'd2: pixel_row = 7'b0001000;
                    3'd3: pixel_row = 7'b0001000;
                    3'd4: pixel_row = 7'b0001000;
                    3'd5: pixel_row = 7'b0001000;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd2: begin  
                case (row)
                    3'd0: pixel_row = 7'b0011100;
                    3'd1: pixel_row = 7'b0100010;
                    3'd2: pixel_row = 7'b0000010;
                    3'd3: pixel_row = 7'b0001100;
                    3'd4: pixel_row = 7'b0010000;
                    3'd5: pixel_row = 7'b0100000;
                    3'd6: pixel_row = 7'b0111110;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd3: begin         
                case (row)
                    3'd0: pixel_row = 7'b0011100;
                    3'd1: pixel_row = 7'b0100010;
                    3'd2: pixel_row = 7'b0000010;
                    3'd3: pixel_row = 7'b0001100;
                    3'd4: pixel_row = 7'b0000010;
                    3'd5: pixel_row = 7'b0100010;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd4: begin  
                case (row)
                    3'd0: pixel_row = 7'b0000100;
                    3'd1: pixel_row = 7'b0001100;
                    3'd2: pixel_row = 7'b0010100;
                    3'd3: pixel_row = 7'b0100100;
                    3'd4: pixel_row = 7'b0111110;
                    3'd5: pixel_row = 7'b0000100;
                    3'd6: pixel_row = 7'b0000100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd5: begin  
                case (row)
                    3'd0: pixel_row = 7'b0111110;
                    3'd1: pixel_row = 7'b0100000;
                    3'd2: pixel_row = 7'b0111100;
                    3'd3: pixel_row = 7'b0000010;
                    3'd4: pixel_row = 7'b0000010;
                    3'd5: pixel_row = 7'b0100010;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd6: begin  
                case (row)
                    3'd0: pixel_row = 7'b0001100;
                    3'd1: pixel_row = 7'b0010000;
                    3'd2: pixel_row = 7'b0100000;
                    3'd3: pixel_row = 7'b0111100;
                    3'd4: pixel_row = 7'b0100010;
                    3'd5: pixel_row = 7'b0100010;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd7: begin  
                case (row)
                    3'd0: pixel_row = 7'b0111110;
                    3'd1: pixel_row = 7'b0000010;
                    3'd2: pixel_row = 7'b0000100;
                    3'd3: pixel_row = 7'b0001000;
                    3'd4: pixel_row = 7'b0010000;
                    3'd5: pixel_row = 7'b0010000;
                    3'd6: pixel_row = 7'b0010000;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd8: begin  
                case (row)
                    3'd0: pixel_row = 7'b0011100;
                    3'd1: pixel_row = 7'b0100010;
                    3'd2: pixel_row = 7'b0100010;
                    3'd3: pixel_row = 7'b0011100;
                    3'd4: pixel_row = 7'b0100010;
                    3'd5: pixel_row = 7'b0100010;
                    3'd6: pixel_row = 7'b0011100;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            4'd9: begin     
                case (row)
                    3'd0: pixel_row = 7'b0011100;
                    3'd1: pixel_row = 7'b0100010;
                    3'd2: pixel_row = 7'b0100010;
                    3'd3: pixel_row = 7'b0011110;
                    3'd4: pixel_row = 7'b0000010;
                    3'd5: pixel_row = 7'b0000100;
                    3'd6: pixel_row = 7'b0011000;
                    default: pixel_row = 7'b0000000;
                endcase
            end
            
            default: pixel_row = 7'b0000000;
        endcase
    end

endmodule