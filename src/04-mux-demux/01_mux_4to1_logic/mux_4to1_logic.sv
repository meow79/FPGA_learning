module mux_4to1_logic(
  input logic [3:0] in,
  input logic [1:0] sel,
  output logic out
);
  logic in0, in1, in2, in3;

  assign in0 = ~(sel[0] | sel[1]) & in[0];
  assign in1 = sel[0] & ~sel[1] & in[1];
  assign in2 = ~sel[0] & sel[1] & in[2];
  assign in3 = sel[0] & sel[1] & in[3];

  assign out = in0 | in1 | in2 | in3;
endmodule
