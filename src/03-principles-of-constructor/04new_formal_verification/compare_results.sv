module compare_results(
  input logic a,
  input logic b
);
  logic p_and_out, s_and_out, p_or_out, s_or_out, p_imp_out, s_imp_out;

  peirce_conjunction p_and(
    .a(a),
    .b(b),
    .res(p_and_out)
  );

  sheffer_conjunction s_and(
    .a(a),
    .b(b),
    .res(s_and_out)
  );


  peirce_disjunction p_or(
    .a(a),
    .b(b),
    .res(p_or_out)
  );

  sheffer_disjunction s_or(
    .a(a),
    .b(b),
    .res(s_or_out)
  );


  peirce_implication p_imp(
    .a(a),
    .b(b),
    .res(p_imp_out)
  );

  sheffer_implication s_imp(
    .a(a),
    .b(b),
    .res(s_imp_out)
  );

  `ifdef FORMAL
    always @* begin
      assert(p_and_out === s_and_out);
      assert(p_or_out === s_or_out);
      assert(p_imp_out === s_imp_out);
    end
  `endif
endmodule
