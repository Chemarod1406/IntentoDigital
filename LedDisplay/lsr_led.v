module lsr_led#(
    parameter init_value = 0,
    parameter width      = 24
) (
    input clk,
    input shift,
    input load,
    input [(width-1):0] data_in,          // Datos a cargar
    output reg [(width-1):0] s_A
);

always @(negedge clk) begin
  if(load)
     s_A <= data_in;                       // Cargar datos nuevos
  else if(shift)
      s_A <= {s_A[(width-2):0], 1'b0};   // Shift left
end

endmodule