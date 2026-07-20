module nor_reduce(
  input logic clk,
  input logic rst,
  input logic cur_bit,
  output logic out
);
  logic acc;
  logic if_first_bit;

  peirce_arrow my_nor(
    .a(acc),
    .b(cur_bit),
    .c(out)
  );

  // NOR operation has no neutral element, so "out" will become correct
  // only after second bit is received
  always_ff @(posedge clk) begin
    if (rst) begin
      acc <= 1'bx;
      if_first_bit <= 1'b1;
    end
    else begin
      if (if_first_bit) begin
        acc <= cur_bit;
        if_first_bit <= 1'b0;
      end else begin
        acc <= out;
      end
    end
  end

  `ifdef FORMAL
    logic past_valid = 1'b0;
    logic [2:0] clk_cnt = '0;
    always @(posedge clk) begin
      past_valid <= 1'b1;
      clk_cnt <= clk_cnt + 1;
    end

    initial begin
      assume (rst);
    end

    always @(posedge clk) begin
      if (past_valid && !rst && $past(rst))
        assert (if_first_bit == 1'b1);
      if (past_valid && !$past(rst) && !$past(if_first_bit))
        assert (out == ~($past(out) | cur_bit));
      if (past_valid && !$past(rst) && $past(if_first_bit))
        assert (out == ~($past(cur_bit) | cur_bit));
    end

    always @(posedge clk) begin
      if (clk_cnt > 2 && !rst && !$past(rst) && !$past(rst, 2) && !$past(rst, 3)) begin
        cover (out == 1'b1 && $past(out) == 1'b0 && $past(out, 2) == 1'b1 &&
               $past(out, 3) == 1'b0 && !$past(if_first_bit, 3));
      end
    end
  `endif
endmodule
