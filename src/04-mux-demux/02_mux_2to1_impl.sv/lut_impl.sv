module lut_impl(
  input logic a, b,
  output logic out
);
  // Если a = 1, то нужно выбрать b. Иначе выбираем 1
  mux_2to1 mux(
    .in0(1'b1),
    .in1(b),
    .sel(a),
    .out(out)
  );
endmodule
