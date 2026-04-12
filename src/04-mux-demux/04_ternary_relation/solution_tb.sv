module solution_tb;
  logic [7:0] AParams = 8'b0000_1111;
  logic [7:0] BParams = 8'b0011_0011;
  logic [7:0] CParams = 8'b0101_0101;

  logic [7:0] OutExpected = 8'b0100_0000;

  logic a, b, c, out;

  solution sol(
    .a(a),
    .b(b),
    .c(c),
    .out(out)
  );

  initial begin
    $write("(NOT(a OR b) AND c) test... ");
    for(int i = 0; i < 8; ++i) begin
      a = AParams[i];
      b = BParams[i];
      c = CParams[i];
      #10;
      assert(out === OutExpected[i])
      else begin
        $display({"\nSomething went wrong:\n",
                   "a = %b, b = %b, c = %b, out = %b, but expected out = %b"},
                   a, b, c, out, OutExpected);
        $fatal;
      end
    end
    $display("OK");
  end
endmodule
