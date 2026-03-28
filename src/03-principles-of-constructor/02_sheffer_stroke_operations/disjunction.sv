module disjunction( // ~a NAND ~b = (a NAND a) NAND (b NAND b)
  input logic a,
  input logic b,
  output logic res
);
  logic not_a, not_b;

  sheffer_stroke nand1(
    .a(a),
    .b(a),
    .c(not_a)
  );
  sheffer_stroke nand2(
    .a(b),
    .b(b),
    .c(not_b)
  );
  sheffer_stroke nand3(
    .a(not_a),
    .b(not_b),
    .c(res)
  );
endmodule
