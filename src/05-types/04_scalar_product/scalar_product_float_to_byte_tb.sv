module scalar_product_float_to_byte_tb;
  localparam int Length = 6;

  logic [Length-1:0][31:0] float_vector;
  logic [Length-1:0][7:0] byte_vector;

  logic [7:0] byte_out;
  logic [8:0] expected;

  scalar_product_float_to_byte #(.VECTORS_LENGTH(Length))
  dut(
    .uint8_vector(byte_vector),
    .float_vector(float_vector),
    .uint8_out(byte_out)
  );

  initial begin
    shortreal float_to_byte;
    byte unsigned float_to_byte_saturated;

    float_vector =
        {$shortrealtobits(12.5), $shortrealtobits(17.22), $shortrealtobits(0.33),
         $shortrealtobits(0.24804688), $shortrealtobits(1.0), $shortrealtobits(0.999999)};
      byte_vector = {8'd10, 8'd2, 8'd36, 8'd155, 8'd15, 8'd6};

    $display("Scalar product float to byte test...");
    $display("---");
    for (int j = 0; j < 2; ++j) begin // 2 tests
      expected = 0;
      // calculate "expected"
      for (int i = 0; i < Length; ++i) begin
        float_to_byte = $bitstoshortreal(float_vector[i]) * byte_vector[i];
        if (float_to_byte < 0)
          float_to_byte_saturated = 0;
        else if (float_to_byte > 255)
          float_to_byte_saturated = 255;
        else
          float_to_byte_saturated = $rtoi(float_to_byte);

        expected += float_to_byte_saturated;
        if (expected > 255)
          expected = 255;
      end

      #10;
      $write("(");
      foreach(float_vector[i]) $write(" %f", $bitstoshortreal(float_vector[i]));
      $display(" )");
      $display("multiply by");
      $write("(");
      foreach(byte_vector[i]) $write(" %0d", byte_vector[i]);
      $display(" )");

      assert(8'(expected) == byte_out) begin
        $display("is %d", byte_out);
      end else begin
        $display("gives %d, but expected %d", byte_out, expected);
        $fatal;
      end

      // change some data for second test
      byte_vector[0] = 100;
      byte_vector[4] = 9;
      float_vector[1] = $shortrealtobits(8.7);
      float_vector[2] = $shortrealtobits(0.98);
      float_vector[4] = $shortrealtobits(3.712);
      $display("---");
    end
    $display("OK");
  end
endmodule
