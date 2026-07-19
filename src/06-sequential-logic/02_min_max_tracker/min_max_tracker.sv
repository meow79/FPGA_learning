module min_max_tracker #(
  parameter int NUM_WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic [NUM_WIDTH - 1:0] num,
  output logic [NUM_WIDTH - 1:0] min,
  output logic [NUM_WIDTH - 1:0] max
);
  always_ff @(posedge clk) begin
    if (rst) begin
      min <= '1;
      max <= '0;
    end else begin
      min <= (num < min) ? num : min;
      max <= (num > max) ? num : max;
    end
  end
endmodule
