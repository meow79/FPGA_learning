module floats_sum_tb;
  localparam int FloatsCnt = 20;

  shortreal floats_in_data [FloatsCnt] = '{0.5, 0.3, 0.2, 5.7, 148.17,
                                           0.0, 0.0001, 1.234567, 38407.12, 28.571041,
                                           -0.3, -0.4, -1.7, -5.7, -8181.1241,
                                           -9.41411, -85.02, -0.5, -54.214142, -1.0};

  shortreal float_in1, float_in2;
  logic [31:0] float_out;
  shortreal true_res;
  logic [31:0] diff;

  floats_sum dut(
    .float_in1($shortrealtobits(float_in1)),
    .float_in2($shortrealtobits(float_in2)),
    .float_out(float_out)
  );

  initial begin
    $write("Module floats_sum test... \n");
    for (int i = 0; i < FloatsCnt; ++i) begin
      for (int j = 0; j < FloatsCnt; ++j) begin
        float_in1 = floats_in_data[i];
        float_in2 = floats_in_data[j];
        true_res = float_in1 + float_in2;

        #10;
        diff = float_out - $shortrealtobits(true_res);
        assert(diff == 0 || diff == 1 || diff == -1) $display("%f + %f = %f",
                                                              float_in1, float_in2, true_res);
        else begin
          $display({"\nSomething went wrong:\n",
                    "float_in1 = %f, float_in2 = %f, float_out = %f, but expected %f"},
                    float_in1, float_in2, $bitstoshortreal(float_out), true_res);
          $display("bits_out: %b\nbits_tru: %b", float_out, $shortrealtobits(true_res));
          $fatal;
        end
      end
    end
    $display("OK");
  end
endmodule
