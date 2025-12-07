module count#(
    parameter width = 5
)(
    input   clk,
    input   reset,
    input   inc,
    output  reg [(width-1):0] outc,
    output  zero
);

always @(negedge clk) begin
  if(reset)  // ← CAMBIO: reset activo ALTO (sin ~)
    outc <= 0;
  else if(inc)
    outc <= outc + 1;
end

assign zero = (outc == 0) ? 1'b1 : 1'b0;

endmodule