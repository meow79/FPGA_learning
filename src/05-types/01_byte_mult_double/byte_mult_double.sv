module byte_mult_double(
  input byte unsigned uint8_in,
  input logic [63:0] double_in,
  output byte unsigned uint8_out
);
  logic [51:0] mantissa;
  logic [10:0] exp;
  logic signed [10:0] shifted_exp;
  logic signed [11:0] shifted_exp_minus_52;
  logic sign;

  logic [63:0] res_64bit;
  logic [63:0] extended_uint8_in;
  logic [63:0] sum_for_rounding;

  assign sign = double_in[63];
  assign mantissa = double_in[51:0];
  assign exp = double_in[62:52];

  always_comb begin
    shifted_exp = $signed({1'b0, exp}) - 11'sd1023;
    shifted_exp_minus_52 = shifted_exp - 52;
    extended_uint8_in = 64'(uint8_in);

    if (shifted_exp_minus_52 >= 0) begin
      if (shifted_exp > 63 && extended_uint8_in != 0)
        res_64bit = 255;
      else
        res_64bit =
          (extended_uint8_in << shifted_exp) +
          ((extended_uint8_in * mantissa) << shifted_exp_minus_52);
    end
    else if (shifted_exp >= 0) begin
      sum_for_rounding = 1 << (-shifted_exp_minus_52 - 1);
      res_64bit =
        (extended_uint8_in << shifted_exp) +
        ((extended_uint8_in * mantissa + sum_for_rounding) >> (-shifted_exp_minus_52));
    end
    else begin
      sum_for_rounding = 1 << (-shifted_exp_minus_52 - 1);
      // Расширение мантиссы единицой справа и последующее деление произведения на 2 ---
      // это прибавление половины эпсилон. Нужно для того, чтобы округлить число до
      // ближайшего, представимого в формате double. Без этого действия, например,
      // 255 * 0.3 = 76,5 округляется до 76, а не до 77 из-за неточного представления 0.3
      // в формате double
      res_64bit =
        ((extended_uint8_in << 52) + ((extended_uint8_in * {mantissa, 1'b1}) >> 1) +
        sum_for_rounding) >> (-shifted_exp_minus_52);
    end

    if (sign === 1'b1)
      uint8_out = 0;
    else if (res_64bit > 255)
      uint8_out = 255;
    else
      uint8_out = 8'(res_64bit);
  end
endmodule
