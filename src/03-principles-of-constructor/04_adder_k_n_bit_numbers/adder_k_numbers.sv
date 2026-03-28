module adder_k_numbers #(
  parameter int COUNT_OF_NUMBERS = 3,
  parameter int COUNT_OF_BITS = 4,
  localparam int ResSize = $clog2(COUNT_OF_NUMBERS) + COUNT_OF_BITS // кол-во бит в результате
) (
  input logic [COUNT_OF_NUMBERS-1:0][COUNT_OF_BITS-1:0] nums, // массив входных чисел (каждое разрядности COUNT_OF_BITS)
  output logic [ResSize-1:0] res
);

  // Сначала складываются первое и второе число, после результат складывается с третьим числом, потом новый результат с четвёртым и т.д.
  logic [COUNT_OF_NUMBERS-1:0][ResSize-1:0] temp; // массив для промежуточных результатов (каждое разрядности ResSize)

  assign temp[0] = ResSize'(nums[0]); // дополняем nums[0] нулями слева до разрядности ResSize
  assign res = temp[COUNT_OF_NUMBERS - 1];

  genvar i;
  generate
    for (i = 1; i < COUNT_OF_NUMBERS; ++i)
      adder_multibits_reuse #(.COUNT_OF_BITS(ResSize))
      add(
        .a(temp[i - 1]),
        .b(ResSize'(nums[i])),
        .c_in(1'b0),    // битов переполнения не будет
        .sum(temp[i]),
        .c_out()
      );
  endgenerate
endmodule
