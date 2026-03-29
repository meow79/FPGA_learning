module bitvector_reduction_or #(
  parameter int SIZE = 8
) (
  input logic [SIZE-1:0] bitvector,
  output logic res
);
  logic [SIZE-1:0] temp_res;

  assign temp_res[0] = bitvector[0];
  assign res = temp_res[SIZE - 1];

  genvar i;
  generate
    for (i = 1; i < SIZE; ++i)
      assign temp_res[i] = temp_res[i - 1] | bitvector[i];
  endgenerate
endmodule
