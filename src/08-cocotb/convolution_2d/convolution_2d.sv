module convolution_2d #(
  parameter int FILTER_SIZE = 3
) (
  input logic clk,
  input logic aresetn,

  input logic weight_valid,
  input logic [$clog2(FILTER_SIZE)-1:0] weight_row,
  input logic [$clog2(FILTER_SIZE)-1:0] weight_col,
  input logic [31:0] weight,

  input logic s_cur_bytes_of_strings_valid,
  output logic s_cur_bytes_of_strings_ready,
  // 'i'-th element is byte from 'i'-th string
  input logic [FILTER_SIZE-1:0][7:0] s_cur_bytes_of_strings,
  input logic s_cur_bytes_of_strings_last,

  output logic m_new_str_byte_valid,
  input logic m_new_str_byte_ready,
  output logic [7:0] m_new_str_byte,
  output logic m_new_str_byte_last
);
  logic [FILTER_SIZE-1:0][FILTER_SIZE-1:0][31:0] filter_ff;

  logic [FILTER_SIZE-1:0][7:0] conv_1d_results_arr;

  genvar i;
  generate
    for (i = 0; i < FILTER_SIZE; ++i) begin: gen_convolution_1d
      if (i == 0) begin: gen_conv_1d_controlling_signals
        convolution_1d #(.FILTER_SIZE(FILTER_SIZE), .FILTER_OF_FLOATS('0))
        conv_1d (
          .clk(clk),
          .aresetn(aresetn),
          .weight_valid((weight_valid && (i == weight_row)) ? '1 : '0),
          .weight_adr(weight_col),
          .weight(weight),
          .s_valid(s_cur_bytes_of_strings_valid),
          .s_ready(s_cur_bytes_of_strings_ready),
          .s_data(s_cur_bytes_of_strings[i]),
          .s_last(s_cur_bytes_of_strings_last),
          .m_valid(m_new_str_byte_valid),
          .m_ready(m_new_str_byte_ready),
          .m_data(conv_1d_results_arr[i]),
          .m_last(m_new_str_byte_last)
        );
      end else begin: gen_conv_1d_other
        convolution_1d #(.FILTER_SIZE(FILTER_SIZE), .FILTER_OF_FLOATS('0))
        conv_1d (
          .clk(clk),
          .aresetn(aresetn),
          .weight_valid((weight_valid && (i == weight_row)) ? '1 : '0),
          .weight_adr(weight_col),
          .weight(weight),
          .s_valid(s_cur_bytes_of_strings_valid),
          .s_ready(),
          .s_data(s_cur_bytes_of_strings[i]),
          .s_last(s_cur_bytes_of_strings_last),
          .m_valid(),
          .m_ready(m_new_str_byte_ready),
          .m_data(conv_1d_results_arr[i]),
          .m_last()
        );
      end
    end
  endgenerate

  always_comb begin
    logic [8:0] sum;
    sum = 0;
    for (int i = 0; i < FILTER_SIZE; ++i) begin
      sum += conv_1d_results_arr[i];
      if (sum > 255) begin
        sum = 255;
      end
    end
    m_new_str_byte = sum;
  end
endmodule
