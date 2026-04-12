module solution(
  input logic a, b, c,
  output logic out
);
  // NOT(a OR b) AND c = NOT(a) AND NOT(b) and c =  NOT(b) AND (NOT(a) AND c)
  // Если не преобразовать выражение, понадобится 3 мультиплексора вроде бы

  logic not_a_and_c;

  // (NOT(a) AND c) -- если a = 0, то c. Иначе 0
  mux_2to1 mux1(
    .in0(c),
    .in1(1'b0),
    .sel(a),
    .out(not_a_and_c)
  );

  // (NOT(b) AND not_a_and_c) -- аналогично
  mux_2to1 mux2(
    .in0(not_a_and_c),
    .in1(1'b0),
    .sel(b),
    .out(out)
  );
endmodule
