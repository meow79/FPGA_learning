module digits_storer_and_incrementer(
  input logic clk_i,
  input logic rst_ni,

  input logic inc_btn_i,
  output logic [3:0] digit_0_ff_o,
  output logic [3:0] digit_1_ff_o
);
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      digit_0_ff_o <= '0;
      digit_1_ff_o <= '0;
    end else begin
      if (inc_btn_i) begin
        if (digit_0_ff_o == 4'd9) begin
          digit_0_ff_o <= '0;
          digit_1_ff_o <= (digit_1_ff_o == 9) ? '0 : (digit_1_ff_o + 1);
        end else begin
          digit_0_ff_o <= digit_0_ff_o + 1;
        end
      end else begin
        digit_0_ff_o <= digit_0_ff_o;
        digit_1_ff_o <= digit_1_ff_o;
      end
    end
  end
endmodule
