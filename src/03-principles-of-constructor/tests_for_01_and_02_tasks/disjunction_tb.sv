module disjunction_tb;
  logic a, b, c;

  const logic [3:0] AParams = 4'b0011;
  const logic [3:0] BParams = 4'b0101;

  const logic [3:0] CExpected = 4'b0111;

  disjunction my_or(
    .a(a),
    .b(b),
    .res(c)
  );

  initial begin
    $write("Disjunction test... ");
    for(int i = 0; i < 4; ++i) begin
      a = AParams[i];
      b = BParams[i];
      #10;
      assert(c === CExpected[i])
      else begin
        $display({"\nSomething went wrong\n",
                  "a = %b, b = %b, c = %b, expected c = %b"},
                  a, b, c, CExpected[i]);
        $fatal;
      end
    end
    $display("OK");
  end
endmodule
