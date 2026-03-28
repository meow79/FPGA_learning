module conjunction( // ~(a NAND b) = (a NAND b) NAND (a NAND b)
  input logic a,
  input logic b,
  output logic res
);
  logic a_nand_b;

  sheffer_stroke nand1(
    .a(a),
    .b(b),
    .c(a_nand_b)
  );
  sheffer_stroke nand2(
    .a(a_nand_b),
    .b(a_nand_b),
    .c(res)
  );
endmodule
