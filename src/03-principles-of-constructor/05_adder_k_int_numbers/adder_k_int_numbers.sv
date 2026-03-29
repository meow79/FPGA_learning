module adder_k_int_numbers #(
  parameter int COUNT_OF_NUMBERS = 5
) (
  input int nums [COUNT_OF_NUMBERS],
  output int sum
);
  int temp_results [COUNT_OF_NUMBERS];

  assign temp_results[0] = nums[0];
  assign sum = temp_results[COUNT_OF_NUMBERS - 1];

  genvar i;
  generate
    for (i = 1; i < COUNT_OF_NUMBERS; ++i)
      adder_int add(
        .a(temp_results[i - 1]),
        .b(nums[i]),
        .sum(temp_results[i])
      );
  endgenerate
endmodule
