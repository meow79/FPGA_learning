module neg_implication_fv(
  input logic a,
  input logic b,
  output logic out
);
  assign out = a & (~b);

  `ifdef FORMAL
    always @* begin
      assert (out === ~((~a) | b));
      cover (b === 1'b0 && out === 1'b1);
    end
  `endif
endmodule
