module mux_4to1_tb;
  logic [3:0] in;
  logic [1:0] sel;
  logic out;
  logic expected_out;

  mux_4to1_logic mux(
    .in(in),
    .sel(sel),
    .out(out)
  );

  initial begin
    $write("4:1 MUX test... ");
    for (int i = 0; i < 64; ++i) begin
      {sel, in} = 6'(i);
      expected_out = in[sel];
      #10;
      assert(out === expected_out)
      else begin
        $display({"\nSomething went wrong:\n",
                  "in = [%b, %b, %b, %b], sel = [%b, %b], out = %b, but expected out = %b"},
                  in[3], in[2], in[1], in[0], sel[1], sel[0], out, expected_out);
        $fatal;
      end
    end
    $display("OK");
  end
endmodule
