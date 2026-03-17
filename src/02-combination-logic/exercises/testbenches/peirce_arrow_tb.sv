module peirce_arrow_tb;

  logic a, b, c;

  const logic [3:0] AParams = 4'b0011;
  const logic [3:0] BParams = 4'b0101;

  const logic [3:0] CExpected = 4'b1000;

  peirce_arrow my_nor(
    .a(a),
    .b(b),
    .c(c)
  );

  initial begin
    $display("Peirce arrow test:");
    for (int i = 0; i < 4; ++i) begin
      a = AParams[i];
      b = BParams[i];
      #10;
      assert(c === CExpected[i])
        $display ("%b nor %b = %b",
                  a, b, c);
      else begin
        $display({"Something went wrong:\n",
                  "a = %b, b = %b, c = %b, expected c = %b"},
                  a, b, c, CExpected[i]);
        $fatal;
      end
    end
  end
endmodule
