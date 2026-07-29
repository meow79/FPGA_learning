module demux_digit(
  input logic [3:0] digit_i,
  output logic [6:0] seven_segment_disp_o
);
  always_comb begin
    unique case (digit_i)
      // PMOD-DTx2 ports:            cab_degf
      'd0: seven_segment_disp_o = 7'b000_0010;
      'd1: seven_segment_disp_o = 7'b010_1111;
      'd2: seven_segment_disp_o = 7'b100_0001;
      'd3: seven_segment_disp_o = 7'b000_0101;
      'd4: seven_segment_disp_o = 7'b010_1100;
      'd5: seven_segment_disp_o = 7'b001_0100;
      'd6: seven_segment_disp_o = 7'b001_0000;
      'd7: seven_segment_disp_o = 7'b000_1111;
      'd8: seven_segment_disp_o = 7'b000_0000;
      'd9: seven_segment_disp_o = 7'b000_0100;
      default: seven_segment_disp_o = 7'b111_1111;
    endcase
  end
endmodule
