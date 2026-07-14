module byte_mult_double_tb;
  localparam int DoubleCnt = 10;
  localparam int ByteCnt = 10;

  byte unsigned byte_in;
  real double_in;
  byte unsigned byte_out;

  const real double_in_data[DoubleCnt] =
    '{10.5, 0.3, 28.76531321111, 5.0, 0.123456789101112,
      20262026.2026, 0.7957130, 278.8814312, 1.934567551, 0.7858491};
  const byte unsigned byte_in_data[ByteCnt] = '{0, 255, 127, 1, 4, 99, 200, 237, 45, 17};

  byte_mult_double byte_mult_double(
    .uint8_in(byte_in),
    .double_in($realtobits(double_in)),
    .uint8_out(byte_out)
  );

  initial begin
    longint true_res;
    byte unsigned expected;

    $write("Module byte_mult_double test... ");
    for (int i = 0; i < DoubleCnt; ++i) begin
      for (int j = 0; j < ByteCnt; ++j) begin
        double_in = double_in_data[i];
        byte_in = byte_in_data[j];

        true_res = longint'(double_in * byte_in);
        if (true_res > 255)
          expected = 255;
        else if (true_res < 0)
          expected = 0;
        else
          expected = true_res;

        #10;
        assert(expected == byte_out)
        else begin
          $display({"\nSomething went wrong:\n",
                    "byte_in = %d, double_in = %f, byte_out = %d, but expected out is %d"},
                    byte_in, double_in, byte_out, expected);
          $fatal;
        end
      end
    end
    $display("OK");
  end
endmodule
