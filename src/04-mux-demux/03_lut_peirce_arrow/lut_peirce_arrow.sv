module lut_peirce_arrow(
  input logic a, b,
  output logic out
);
  mux_4to1_logic mux(
    .in({1'b0, 1'b0, 1'b0, 1'b1}),
    .sel({a, b}),
    .out(out)
  );
endmodule
