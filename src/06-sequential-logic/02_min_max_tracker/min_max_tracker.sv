module min_max_tracker #(
  parameter int NUM_WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic [NUM_WIDTH - 1:0] num,
  output logic [NUM_WIDTH - 1:0] min,
  output logic [NUM_WIDTH - 1:0] max
);
  logic [NUM_WIDTH - 1:0] min_reg, max_reg;

  assign min = (num < min_reg) ? num : min_reg;
  assign max = (num > max_reg) ? num : max_reg;

  always_ff @(posedge clk) begin
    if (rst) begin
      min_reg <= '1;
      max_reg <= '0;
    end else begin
      min_reg <= min;
      max_reg <= max;
    end
  end
endmodule
