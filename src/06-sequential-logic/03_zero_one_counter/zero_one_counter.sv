module zero_one_counter (
  input logic clk,
  input logic rst,
  input logic cur_bit,
  output logic [31:0] zero_cnt,
  output logic [31:0] one_cnt
);
  always_ff @(posedge clk) begin
    if (rst) begin
      zero_cnt <= 0;
      one_cnt <= 0;
    end else begin
      zero_cnt <= zero_cnt + (!cur_bit);
      one_cnt <= one_cnt + cur_bit;
    end
  end
endmodule
