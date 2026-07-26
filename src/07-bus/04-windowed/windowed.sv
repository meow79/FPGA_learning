module windowed #(
  parameter int DATA_WIDTH = 1,
  parameter int WINDOW_SIZE = 3
) (
  input logic clk,
  input logic aresetn,

  // Input from master
  input logic s_valid,
  output logic s_ready,
  input logic [DATA_WIDTH-1:0] s_data,

  // Output to slave
  output logic m_valid,
  input logic m_ready,
  output logic [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] m_data
);
  logic [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] window_ff;
  logic windows_started_ff;
  logic valid_ff;

  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      window_ff[WINDOW_SIZE-1] <= 1'b1; // marker to control windows_started_ff
    end else if (s_valid && s_ready) begin
      window_ff <= {s_data, window_ff[WINDOW_SIZE-1:1]};
    end
  end

  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      valid_ff <= '0;
      windows_started_ff <= '0;
    end else begin
      if (m_valid && m_ready) begin
        valid_ff <= '0;
      end

      if (s_valid && s_ready) begin
        if (windows_started_ff) begin
          valid_ff <= '1;
        end else if (!windows_started_ff && window_ff[0] == 1'b1) begin
          windows_started_ff <= '1;
          valid_ff <= '1;
        end
      end
    end
  end

  always_comb begin
    m_valid = valid_ff;
    s_ready = !(m_valid && !m_ready);
    m_data = window_ff;
  end


endmodule
