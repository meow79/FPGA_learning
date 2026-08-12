module convolution_1d #(
  parameter int FILTER_SIZE = 3, // should be odd number > 1
  parameter logic [FILTER_SIZE*32-1:0] FILTER_OF_FLOATS
) (
  input logic clk,
  input logic aresetn,

  // Input from master
  input logic s_valid,
  output logic s_ready,
  input logic [7:0] s_data,
  input logic s_last,

  // Output to slave
  output logic m_valid,
  input logic m_ready,
  output logic [7:0] m_data,
  output logic m_last
);
  localparam int PaddingSize = FILTER_SIZE / 2;

  logic s_valid_to_windowed;
  logic s_ready_from_windowed;
  logic [7:0] s_data_to_windowed;
  logic s_last_to_windowed;

  logic [FILTER_SIZE-1:0][7:0] current_input_slice;

  windowed #(.DATA_WIDTH(8), .WINDOW_SIZE(FILTER_SIZE))
  slicer(
    .clk(clk),
    .aresetn(aresetn),
    .s_valid(s_valid_to_windowed),
    .s_ready(s_ready_from_windowed),
    .s_data(s_data_to_windowed),
    .s_last(s_last_to_windowed),
    .m_valid(m_valid),
    .m_ready(m_ready),
    .m_data(current_input_slice),
    .m_last(m_last)
  );

  scalar_product_float_to_byte #(.VECTORS_LENGTH(FILTER_SIZE))
  scalar_product(
    .uint8_vector(current_input_slice),
    .float_vector(FILTER_OF_FLOATS), // implicit cast to 2d packed array
    .uint8_out(m_data)
  );

  logic [$clog2(PaddingSize + 1)-1:0] needed_padding_length;
  logic cur_input_vec_is_over;

  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      needed_padding_length <= PaddingSize;
      cur_input_vec_is_over <= '0;
      s_last_to_windowed <= '0;
    end else begin
      if (s_last_to_windowed && s_ready_from_windowed) begin
        s_last_to_windowed <= '0;
      end

      if (s_valid && s_ready && s_last) begin
        needed_padding_length <= PaddingSize;
        cur_input_vec_is_over <= '1;
        if (PaddingSize == 1) begin
          s_last_to_windowed <= '1;
        end
      end
      else if (needed_padding_length > 0 && s_ready_from_windowed) begin
        if (needed_padding_length == 2 && cur_input_vec_is_over) begin
          s_last_to_windowed <= '1;
          needed_padding_length <= 1;
        end else if (needed_padding_length == 1 && cur_input_vec_is_over) begin
          cur_input_vec_is_over <= '0;
          needed_padding_length <= PaddingSize;
        end else begin
          needed_padding_length <= needed_padding_length - 1;
        end
      end
    end
  end

  always_comb begin
    if (needed_padding_length > 0) begin
      s_valid_to_windowed = '1;
      s_data_to_windowed = '0;

      s_ready = '0;
    end else begin
      s_valid_to_windowed = s_valid;
      s_data_to_windowed = s_data;

      s_ready = s_ready_from_windowed;
    end
  end
endmodule
