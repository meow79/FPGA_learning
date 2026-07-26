module pairwise(
  input logic clk,
  input logic aresetn,

  // Input from master
  input logic s_valid,
  output logic s_ready,
  input logic s_data,

  // Output to slave
  output logic m_valid,
  input logic m_ready,
  output logic [1:0] m_data
);
  logic [1:0] data_ff;
  logic is_first_bit_ff;
  logic valid_ff;

  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      data_ff <= '0;
    end else if (s_valid && s_ready) begin
      data_ff <= {s_data, data_ff[1]};
    end
  end

  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      valid_ff <= '0;
      is_first_bit_ff <= '1;
    end else begin
      if (m_valid && m_ready) begin
        valid_ff <= '0;
      end

      if (s_valid && s_ready) begin
        if (is_first_bit_ff) begin
          is_first_bit_ff <= '0;
        end else begin
          valid_ff <= '1;
        end
      end
    end
  end

  always_comb begin
    m_valid = valid_ff;
    s_ready = !(m_valid && !m_ready);
    m_data = data_ff;
  end
endmodule
