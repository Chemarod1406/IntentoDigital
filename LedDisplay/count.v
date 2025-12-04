module count#(
    parameter width = 5
)(
    input   clk,
    input   reset,      // Reset Activo en ALTO (1 = Borrar)
    input   inc,
    output  reg [(width-1):0] outc,
    output  zero
);

always @(negedge clk) begin
  if(reset)           // Si reset=1, resetear contador
    outc <= 0;
  else if(inc)        // Si inc=1, incrementar
    outc <= outc + 1;
end

// Detectar cuando el contador llega al máximo y vuelve a 0
assign zero = (outc == {width{1'b1}});  // Todos los bits en 1 = máximo valor

endmodule