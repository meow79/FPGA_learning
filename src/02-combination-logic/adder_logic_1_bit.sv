module adder_logic_1_bit (
    input logic a,
    input logic b,
    input logic c_in,
    output logic c_out,
    output logic sum
);
  assign sum = a ^ b ^ c_in;

  assign c_out = (a & b) | (c_in & (a ^ b));
endmodule
