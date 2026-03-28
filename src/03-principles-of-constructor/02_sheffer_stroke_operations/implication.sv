module implication( // a NAND ~b = a NAND (b NAND b)
  input logic a,
  input logic b,
  output logic res
);
  logic not_b;

  sheffer_stroke nand1(
    .a(b),
    .b(b),
    .c(not_b)
  );
  sheffer_stroke nand2(
    .a(a),
    .b(not_b),
    .c(res)
  );
endmodule
