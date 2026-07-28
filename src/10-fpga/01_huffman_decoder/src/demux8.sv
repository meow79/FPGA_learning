module demux8 (
    input  logic [3:0] number_i,
    output logic [7:0] select_o
);
  always_comb begin
    unique case (number_i)
      'd1: select_o = 8'b00000001;
      'd2: select_o = 8'b00000010;
      'd3: select_o = 8'b00000100;
      'd4: select_o = 8'b00001000;
      'd5: select_o = 8'b00010000;
      'd6: select_o = 8'b00100000;
      'd7: select_o = 8'b01000000;
      'd8: select_o = 8'b10000000;
      default: select_o = '0;
    endcase
  end
endmodule
