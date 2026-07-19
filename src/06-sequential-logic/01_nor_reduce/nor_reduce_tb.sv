module nor_reduce_tb;
  initial begin
    $dumpfile("build/nor_reduce_tb.vcd");
    $dumpvars(0, nor_reduce_tb);
  end

  logic clk, rst;
  logic cur_bit;
  logic convolution_result;

  localparam int ClkPeriod = 10;

  nor_reduce DUT(
    .clk(clk),
    .rst(rst),
    .cur_bit(cur_bit),
    .out(convolution_result)
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
    $monitor("clk = %d, rst = %d, cur_bit = %d, convolution_result = %d",
             clk, rst, cur_bit, convolution_result);

    wait(!rst) cur_bit <= 0;
    @(posedge clk) cur_bit <= 1;
    @(posedge clk) cur_bit <= 0;
    @(posedge clk) cur_bit <= 0;
    @(posedge clk) cur_bit <= 1;
    @(posedge clk) cur_bit <= 1;
    @(posedge clk) $finish();
  end
endmodule
