module conjunction( // (a NOR a) NOR (b NOR b)
  input logic a,
  input logic b,
  output logic res
);
  logic not_a, not_b;

  peirce_arrow nor1(
    .a(a),
    .b(a),
    .c(not_a)
  );
  peirce_arrow nor2(
    .a(b),
    .b(b),
    .c(not_b)
  );
  peirce_arrow nor3(
    .a(not_a),
    .b(not_b),
    .c(res)
  );
endmodule
