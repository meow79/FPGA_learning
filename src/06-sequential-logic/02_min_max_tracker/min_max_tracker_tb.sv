module min_max_tracker_tb;
  initial begin
    $dumpfile("build/min_max_tracker_tb.vcd");
    $dumpvars(0, min_max_tracker_tb);
  end

  localparam int NumWidth = 8;
  localparam int ClkPeriod = 10;

  logic clk, rst;
  logic [NumWidth - 1:0] cur_num, min, max;

  min_max_tracker #(.NUM_WIDTH(NumWidth))
  tracker (
    .clk(clk),
    .rst(rst),
    .num(cur_num),
    .min(min),
    .max(max)
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
    $monitor("clk = %d, rst = %d, cur_num = %d, min = %d, max = %d",
             clk, rst, cur_num, min, max);

    wait(!rst) cur_num <= 8'd5;
    @(posedge clk) cur_num <= 8'd17;
    @(posedge clk) cur_num <= 8'd98;
    @(posedge clk) cur_num <= 8'd85;
    @(posedge clk) cur_num <= 8'd1;
    @(posedge clk) cur_num <= 8'd59;

    @(posedge clk) rst <= 1'b1;
    @(posedge clk) rst <= 1'b0;
    cur_num <= 8'd240;
    @(posedge clk) cur_num <= 8'd242;
    @(posedge clk) cur_num <= 8'd242;
    @(posedge clk) cur_num <= 8'd98;
    @(posedge clk) cur_num <= 8'd255;
    @(posedge clk) cur_num <= 8'd9;
    @(posedge clk) $finish();
  end
endmodule
