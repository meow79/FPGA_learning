module disjunction( // (a NOR b) NOR (a NOR b)
  input logic a,
  input logic b,
  output logic res
);
  logic a_nor_b;

  peirce_arrow nor1(
    .a(a),
    .b(b),
    .c(a_nor_b)
  );
  peirce_arrow nor2(
    .a(a_nor_b),
    .b(a_nor_b),
    .c(res)
  );
endmodule
