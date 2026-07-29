module PMOD_DTx2_controller(
  input logic clk_i,
  input logic [3:0] digit_0_i,
  input logic [3:0] digit_1_i,
  output logic [7:0] PMOD_DTx2_out
);
  logic [6:0] seven_seg_disp_0;
  logic [6:0] seven_seg_disp_1;

  demux_digit demux_seven_seg_disp_0(
    .digit_i(digit_0_i),
    .seven_segment_disp_o(seven_seg_disp_0)
  );

  demux_digit demux_seven_seg_disp_1(
    .digit_i(digit_1_i),
    .seven_segment_disp_o(seven_seg_disp_1)
  );

  // clk_cnt нужен, чтобы переключать селектор семисегментного индикатора с подходящей
  // частотой: не слишком высокой(для корректной работы) и не слишком низкой(чтобы человеческому
  // глазу казалось, что оба индикатора горят одновременно)
  logic [18:0] clk_cnt = 0;
  always_ff @(posedge clk_i) begin
    clk_cnt <= clk_cnt + 1;
  end

  logic sel;
  assign sel = clk_cnt[18];

  // Добавление бита, отвечающего за селектор
  assign PMOD_DTx2_out = (sel) ? {1'b0, seven_seg_disp_1} : {1'b1, seven_seg_disp_0};
endmodule
