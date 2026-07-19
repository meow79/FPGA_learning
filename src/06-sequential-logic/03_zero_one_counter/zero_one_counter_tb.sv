module zero_one_counter_tb;
  initial begin
    $dumpfile("build/zero_one_counter_tb.vcd");
    $dumpvars(0, zero_one_counter_tb);
  end

 localparam int ClkPeriod = 10;

  logic clk, rst;
  logic cur_bit;
  logic [31:0] zero_cnt, one_cnt;

  zero_one_counter counter(
    .clk(clk),
    .rst(rst),
    .cur_bit(cur_bit),
    .zero_cnt(zero_cnt),
    .one_cnt(one_cnt)
  );

  initial begin
    rst <= 1'b1;
    #(ClkPeriod);
    rst <= 1'b0;
  end

  initial begin
    clk <= 1'b0;
    forever begin
      #(ClkPeriod / 2) clk <= ~clk;
    end
  end

  initial begin
    $monitor("clk = %d, rst = %d, cur_bit = %d, zero_cnt = %d, one_cnt = %d",
             clk, rst, cur_bit, zero_cnt, one_cnt);

    wait(!rst) cur_bit <= 1'b0;
    @(posedge clk) cur_bit <= 1'b1;
    @(posedge clk) cur_bit <= 1'b0;
    @(posedge clk) cur_bit <= 1'b1;
    @(posedge clk) cur_bit <= 1'b1;
    @(posedge clk) cur_bit <= 1'b1;
    @(posedge clk) cur_bit <= 1'b0;
    @(posedge clk) cur_bit <= 1'b0;
    @(posedge clk) cur_bit <= 1'b1;
    @(posedge clk) $finish();
  end
endmodule
