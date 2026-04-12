module mux_4to1_logic(
  input logic [3:0] in,
  input logic [1:0] sel,
  output logic out
);
  logic res0, res1;

  assign res0 = (sel[0] & in[1]) | (~sel[0] & in[0]);
  assign res1 = (sel[0] & in[3]) | (~sel[0] & in[2]);

  assign out = (sel[1] & res1) | (~sel[1] & res0);
endmodule
