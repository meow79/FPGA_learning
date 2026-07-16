// Fails 8 out of 200 substraction tests. 3-4 last bits of result's mantissa are wrong.
// I don't know, how to fix it.

module floats_sum(
  input logic [31:0] float_in1,
  input logic [31:0] float_in2,
  output logic [31:0] float_out
);
  byte unsigned exp1, exp2;
  logic [22:0] mantissa1, mantissa2, mantissa_res;
  logic sign1, sign2, sign_res;

  byte shifted_exp1, shifted_exp2, shifted_exp_res;

  always_comb begin
    exp1 = float_in1[30:23];
    exp2 = float_in2[30:23];
    mantissa1 = float_in1[22:0];
    mantissa2 = float_in2[22:0];
    sign1 = float_in1[31];
    sign2 = float_in2[31];

    shifted_exp1 = $signed(exp1) - 127;
    shifted_exp2 = $signed(exp2) - 127;

    // Swap input numbers if float_in1 < float_in2
    if (shifted_exp1 < shifted_exp2) begin
      byte temp_shifted_exp;
      logic [22:0] mantissa_temp;
      logic sign_temp;

      temp_shifted_exp = shifted_exp1; shifted_exp1 = shifted_exp2; shifted_exp2 = temp_shifted_exp;
      mantissa_temp = mantissa1; mantissa1 = mantissa2; mantissa2 = mantissa_temp;
      sign_temp = sign1; sign1 = sign2; sign2 = sign_temp;
    end

    if (((float_in1 & 32'h7fff_ffff) == 0) && ((float_in2 & 32'h7fff_ffff) == 0)) begin
      // then float_in1 = float_in2 = 0
      shifted_exp_res = -127;
      mantissa_res = 0;
    end
    else if (sign1 == sign2) begin // ADD
      logic [23:0] sum_of_mantisses;
      logic rounding_mantissa_bit;
      sign_res = sign1;

      if (shifted_exp1 == shifted_exp2) begin
        sum_of_mantisses = mantissa1 + mantissa2;
        shifted_exp_res = shifted_exp1 + 1;
        rounding_mantissa_bit = sum_of_mantisses[0];
        mantissa_res = sum_of_mantisses[23:1] + rounding_mantissa_bit;
      end
      else begin
        logic [23:0] mantissa2_with_implicit_1;
        logic [22:0] shifted_mantissa2;

        mantissa2_with_implicit_1 = {1'b1, mantissa2};
        shifted_mantissa2 = mantissa2_with_implicit_1 >> (shifted_exp1 - shifted_exp2);

        sum_of_mantisses = mantissa1 + shifted_mantissa2;
        if (sum_of_mantisses[23] == 1'b0) begin
          shifted_exp_res = shifted_exp1;
          rounding_mantissa_bit = (shifted_exp1 - shifted_exp2 - 1 < 24) ?
            mantissa2_with_implicit_1[shifted_exp1 - shifted_exp2 - 1] : 0;
          mantissa_res = sum_of_mantisses[22:0] + rounding_mantissa_bit;
        end
        else begin
          shifted_exp_res = shifted_exp1 + 1;
          rounding_mantissa_bit = sum_of_mantisses[0];
          mantissa_res = {1'b0, sum_of_mantisses[22:1]} + rounding_mantissa_bit;
        end
      end
    end
    else begin // SUB
      logic [22:0] res_mantissa_before_shift;
      logic need_to_shift_res_mantissa;
      logic [22:0] shifted_mantissa2;
      logic [23:0] mantissa2_with_implicit_1;
      res_mantissa_before_shift = 0;
      need_to_shift_res_mantissa = 0;
      mantissa2_with_implicit_1 = {1'b1, mantissa2};
      shifted_mantissa2 = mantissa2_with_implicit_1 >> (shifted_exp1 - shifted_exp2);

      if (shifted_exp1 == shifted_exp2) begin
        if (mantissa1 == mantissa2) begin
          sign_res = 0;
          shifted_exp_res = -127;
          mantissa_res = 0;
        end else if (mantissa1 > mantissa2) begin
          sign_res = sign1 ? 1 : 0;
          res_mantissa_before_shift = mantissa1 - mantissa2;
          need_to_shift_res_mantissa = 1;
        end else begin
          sign_res = sign2 ? 1 : 0  ;
          res_mantissa_before_shift = mantissa2 - mantissa1;
          need_to_shift_res_mantissa = 1;
        end
      end
      else if (mantissa1 >= shifted_mantissa2) begin
        shifted_exp_res = shifted_exp1; // same exponent, don't need to shift mantissa
        if (mantissa1 == shifted_mantissa2)
          mantissa_res = 0;
        else begin
          logic rounding_mantissa_bit;
          rounding_mantissa_bit =
            (shifted_exp1 - shifted_exp2 - 1 < 24) ?
            mantissa2_with_implicit_1[shifted_exp1 - shifted_exp2 - 1] : 0;
          mantissa_res = mantissa1 - (shifted_mantissa2 + rounding_mantissa_bit);
        end
        sign_res = sign1 ? 1 : 0;
      end
      else begin
        res_mantissa_before_shift = (1 << 23) + mantissa1 - shifted_mantissa2;
        sign_res = sign1 ? 1 : 0;
        need_to_shift_res_mantissa = 1;
      end

      if (need_to_shift_res_mantissa) begin
        logic[23:0] rounding;
        logic [4:0] clz;
        clz = 0;
        for (int i = 0; i < 23; ++i) begin
          if (res_mantissa_before_shift[22 - i] == 1'b1) begin
            clz = i;
            i = 23;
          end
        end
        // bits lost during right shift mantissa2_with_implicit_1
        rounding = ((shifted_exp1 - shifted_exp2) <= (clz + 1)) ?
          (mantissa2_with_implicit_1 & ((1 << (shifted_exp1 - shifted_exp2)) - 1)) <<
          (clz + 1 - (shifted_exp1 - shifted_exp2)) :
          ((mantissa2_with_implicit_1 >> ((shifted_exp1 - shifted_exp2) - (clz + 1))) &
          ((1 << (clz + 1)) - 1)) +
          ((mantissa2_with_implicit_1 >> ((shifted_exp1 - shifted_exp2) - (clz + 2))) & 1); // <- round bit

        mantissa_res = (res_mantissa_before_shift << (clz + 1)) - rounding;
        shifted_exp_res = shifted_exp1 - (clz + 1);
      end
    end

    float_out = {sign_res, shifted_exp_res + 8'd127, mantissa_res};
  end
endmodule
