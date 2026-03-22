module implication( // ((a NOR a) NOR b) NOR ((a NOR a) NOR b)
  input logic a,
  input logic b,
  output logic res
);
  logic not_a;
  logic not_a_nor_b;

  peirce_arrow nor1(
    .a(a),
    .b(a),
    .c(not_a)
  );
  peirce_arrow nor2(
    .a(not_a),
    .b(b),
    .c(not_a_nor_b)
  );
  peirce_arrow nor3(
    .a(not_a_nor_b),
    .b(not_a_nor_b),
    .c(res)
  );
endmodule
