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
endmodule
