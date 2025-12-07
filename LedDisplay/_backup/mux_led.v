module mux_led(
    input  [23:0]    in0,  // R0[7:4]G0[7:4]B0[7:4] R1[7:4]G1[7:4]B1[7:4]
    input  [1:0]     sel,
    output reg [5:0] out0  // R0G0B0R1G1B1
);

  // Formato de entrada: in0[23:0]
  // Bits 23-20: R0 (4 bits más significativos del rojo superior)
  // Bits 19-16: G0 (4 bits más significativos del verde superior)
  // Bits 15-12: B0 (4 bits más significativos del azul superior)
  // Bits 11-8:  R1 (4 bits más significativos del rojo inferior)
  // Bits 7-4:   G1 (4 bits más significativos del verde inferior)
  // Bits 3-0:   B1 (4 bits más significativos del azul inferior)

  always @*
  begin
      case (sel)
        2'b00: out0 = {in0[23], in0[19], in0[15], in0[11], in0[7],  in0[3]};  // MSB
        2'b01: out0 = {in0[22], in0[18], in0[14], in0[10], in0[6],  in0[2]};
        2'b10: out0 = {in0[21], in0[17], in0[13], in0[9],  in0[5],  in0[1]};
        2'b11: out0 = {in0[20], in0[16], in0[12], in0[8],  in0[4],  in0[0]};  // LSB
        default: out0 = 6'b000000;
      endcase
  end

endmodule