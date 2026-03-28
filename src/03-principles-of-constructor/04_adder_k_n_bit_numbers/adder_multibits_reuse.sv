module adder_multibits_reuse #(
  parameter int COUNT_OF_BITS = 4
) (
  input logic [COUNT_OF_BITS-1:0] a,
  input logic [COUNT_OF_BITS-1:0] b,
  input logic c_in,
  output logic [COUNT_OF_BITS-1:0] sum,
  output logic c_out
);
  logic [COUNT_OF_BITS:0] carry_temp;

  assign carry_temp[0] = c_in;
  assign c_out = carry_temp[COUNT_OF_BITS];

  genvar i;
  generate
    for (i = 0; i < COUNT_OF_BITS; ++i)
      adder_logic_1_bit add(
        .a(a[i]),
        .b(b[i]),
        .c_in(carry_temp[i]),
        .sum(sum[i]),
        .c_out(carry_temp[i + 1])
      );
  endgenerate
endmodule
