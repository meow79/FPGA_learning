module float_mult_byte (
    input  logic [31:0] float_in,
    input  byte unsigned uint8_in,
    output byte unsigned uint8_out,
    output logic is_out_nan
);

  logic         sign;
  byte unsigned exponent;
  logic [22:0]  mantissa;

  byte         exp_shift;
  logic [31:0] scaled_mantissa;
  logic [31:0] mantissa_to_uint;
  logic [31:0] uint_extended;
  logic [32:0] fraction_sum;

  always_comb begin

    sign          = float_in[31];
    exponent      = float_in[30:23];
    mantissa      = float_in[22:0];

    is_out_nan = 0;
    if (exponent == 255) begin // special cases
      if (mantissa == 0) begin // +(-)inf
        if (uint8_in == 0) begin
          uint8_out = 0;
          is_out_nan = 1;
        end else if (sign)
          uint8_out = 0;
        else
          uint8_out = 255;
      end else begin // nan
        uint8_out = 0;
        is_out_nan = 1;
      end
    end else begin // normal cases
      exp_shift = exponent - 8'd127;
      uint_extended = uint8_in;

      if ((exp_shift - 23) >= 0)
        if (exp_shift > 31 && uint_extended)
          scaled_mantissa = 255;
        else
          scaled_mantissa =
            ((mantissa * uint8_in) << (exp_shift - 23)) +
            (uint_extended << exp_shift);
      else if (exp_shift >= 0) begin
        mantissa_to_uint = mantissa * uint8_in;
        scaled_mantissa =
          (mantissa_to_uint >> (-(exp_shift - 23))) +
          (uint_extended << exp_shift);
      end else begin
        mantissa_to_uint = mantissa * uint8_in;
        if ((uint_extended << (32 + exp_shift)) == 0)
          fraction_sum  = (mantissa_to_uint << (32 + (exp_shift - 23)));
        else
          fraction_sum =
            (mantissa_to_uint << (32 + (exp_shift - 23))) +
            (uint_extended << (32 + exp_shift));
        scaled_mantissa =
          (mantissa_to_uint >> -(exp_shift - 23)) +
          (uint_extended >> -exp_shift) + fraction_sum[32];
      end

      if (sign) begin
        uint8_out = 0;
      end else if (scaled_mantissa > 255) begin
        uint8_out = 8'd255;
      end else begin
        uint8_out = scaled_mantissa[7:0];
      end
    end
  end
endmodule
