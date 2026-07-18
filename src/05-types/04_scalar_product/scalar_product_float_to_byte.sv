module scalar_product_float_to_byte #(
  parameter int VECTORS_LENGTH = 8
) (
  input byte unsigned uint8_vector [VECTORS_LENGTH],
  input logic [31:0] float_vector [VECTORS_LENGTH],
  output byte unsigned uint8_out
);
  byte unsigned mult_results_vector [VECTORS_LENGTH];
  byte unsigned temp_sums [VECTORS_LENGTH];

  assign temp_sums[0] = mult_results_vector[0];
  assign uint8_out = temp_sums[VECTORS_LENGTH - 1];

  genvar i;
  generate
    for (i = 0; i < VECTORS_LENGTH; ++i) begin
      float_mult_byte mult(
        .float_in(float_vector[i]),
        .uint8_in(uint8_vector[i]),
        .uint8_out(mult_results_vector[i])
      );
    end
  endgenerate

  genvar j;
  generate
    for (j = 1; j < VECTORS_LENGTH; ++j) begin
      logic [8:0] sum;
      assign sum = temp_sums[j - 1] + mult_results_vector[j];
      assign temp_sums[j] = (sum > 255) ? 255 : sum;
    end
  endgenerate
endmodule
