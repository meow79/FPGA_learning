module zero_one_counter (
  input logic clk,
  input logic rst,
  input logic cur_bit,
  output logic [31:0] zero_cnt,
  output logic [31:0] one_cnt
);
  logic [31:0] zero_cnt_reg, one_cnt_reg;

  assign zero_cnt = zero_cnt_reg + (!cur_bit);
  assign one_cnt = one_cnt_reg + cur_bit;

  always_ff @(posedge clk) begin
    if (rst) begin
      zero_cnt_reg <= 0;
      one_cnt_reg <= 0;
    end else begin
      zero_cnt_reg <= zero_cnt;
      one_cnt_reg <= one_cnt;
    end
  end
endmodule
