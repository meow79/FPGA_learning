`timescale 1ns / 1ps

module merge_parallel_tb;
  localparam int InWidth_1 = 3;
  localparam int InWidth_2 = 8;

  logic clk, aresetn;
  logic s_valid_1, s_ready_1, s_valid_2, s_ready_2;
  logic [InWidth_1-1:0] s_data_1;
  logic [InWidth_2-1:0] s_data_2;

  logic m_valid, m_ready;
  logic [InWidth_1+InWidth_2-1:0] m_data;

  merge_parallel #(
    .IN_WIDTH_1(InWidth_1),
    .IN_WIDTH_2(InWidth_2)
  ) DUT (
    .clk(clk),
    .aresetn(aresetn),
    .s_valid_1(s_valid_1),
    .s_ready_1(s_ready_1),
    .s_data_1(s_data_1),
    .s_valid_2(s_valid_2),
    .s_ready_2(s_ready_2),
    .s_data_2(s_data_2),
    .m_valid(m_valid),
    .m_ready(m_ready),
    .m_data(m_data)
  );

  localparam ClkPeriod = 10;

  initial begin
    aresetn <= 1'b0;
    #(ClkPeriod);
    aresetn <= 1'b1;
  end

  initial begin
    clk <= 1'b0;
    forever begin
      #(ClkPeriod / 2) clk <= ~clk;
    end
  end

  localparam int NOfIterations = 10000;

  // First parallel input logic
  initial begin
    wait (!aresetn);
    s_valid_1 <= '0;
    s_data_1 <= '0;
    wait (aresetn);

    repeat (NOfIterations) begin
      repeat (InWidth_1) @(posedge clk);
      s_valid_1 <= '1;
      s_data_1 <= $urandom();
      do begin
        @(posedge clk);
      end while (!s_ready_1);
      s_valid_1 <= '0;
    end
    $finish();
  end

  // Second parallel input logic
  initial begin
    wait(!aresetn);
    s_valid_2 <= '0;
    s_data_2 <= '0;
    wait(aresetn);

    repeat (NOfIterations) begin
      repeat (InWidth_2) @(posedge clk);
      s_valid_2 <= '1;
      s_data_2 <= $urandom();
      do begin
        @(posedge clk);
      end while (!s_ready_2);
      s_valid_2 <= '0;
    end
    $finish();
  end

  // Slave logic
  initial begin
    wait(!aresetn);
    m_ready <= $urandom();
    wait(aresetn);
    forever begin
      @(posedge clk) m_ready <= $urandom();
    end
  end

  // Main logic for test DUT
  logic [InWidth_1-1:0] part1;
  logic [InWidth_2-1:0] part2;
  logic part1_valid, part2_valid;
  initial begin
    wait(aresetn);
    forever begin
      @(posedge clk);
      if (s_valid_1 && s_ready_1) begin
        part1 <= s_data_1;
        part1_valid <= '1;
      end
      if (s_valid_2 && s_ready_2) begin
        part2 <= s_data_2;
        part2_valid <= '1;
      end
    end
  end

  initial begin
    wait(aresetn);
    forever begin
      @(posedge clk);
      if (m_data != {part2, part1}) begin
        $error("%0t Incorrect m_data. Expected: %b. Actual: %b",
               $time(), {part2, part1}, m_data);
      end
      if (m_valid) begin
        if (!(part1_valid && part2_valid)) begin
          $error("%0t Incorrect m_valid. Expected: 0. Actual: 1", $time());
        end

        if (m_ready) begin
          part1_valid <= '0;
          part2_valid <= '0;
        end
      end
    end
  end

  initial begin
    repeat (100000000) @(posedge clk);
    $stop();
  end

  `ifdef __ICARUS__
    initial begin
      $dumpfile("build/merge_parallel_tb.vcd");
      $dumpvars(0, merge_parallel_tb);
    end
  `endif

endmodule
