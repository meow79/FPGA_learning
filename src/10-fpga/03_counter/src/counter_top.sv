module counter_top(
  input logic clk_i,
  input logic rst_btn_i,
  input logic inc_btn_i,

  output logic [7:0] PMOD_DTx2_out
);
  logic inc_btn_db;

  debouncer inv_inc_btn_debouncer(
    .clk_i(clk_i),
    .rst_ni(rst_btn_i),
    .btn_i(inc_btn_i),
    .btn_db_o(inc_btn_db)
  );

  logic inc_btn;
  re_detector inc_btn_re_detector(
    .clk_i(clk_i),
    .rst_ni(rst_btn_i),
    .in_i(inc_btn_db),
    .out_o(inc_btn)
  );

  logic [3:0] digit_0;
  logic [3:0] digit_1;

  digits_storer_and_incrementer incrementer(
    .clk_i(clk_i),
    .rst_ni(rst_btn_i),
    .inc_btn_i(inc_btn),
    .digit_0_ff_o(digit_0),
    .digit_1_ff_o(digit_1)
  );

  PMOD_DTx2_controller controller(
    .clk_i(clk_i),
    .digit_0_i(digit_0),
    .digit_1_i(digit_1),
    .PMOD_DTx2_out(PMOD_DTx2_out)
  );
endmodule
