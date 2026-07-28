module huffman_led_modified (
  // inputs
  input  logic [0:0]   btn_0_i,
  input  logic [0:0]   btn_1_i,
  // outputs
  output logic [3:0]   number_o,
  // clock and reset
  input  logic         clk_i,
  input  logic         rst_ni
);

// number | code
//   1    | 000
//   2    | 001
//   3    | 010
//   4    | 011
//   5    | 100
//   6    | 101
//   7    | 110
//   8    | 111

`ifdef USE_ENUM_STATE
  typedef enum logic [6:0] {
    Start = 7'd1,
    Zero = 7'd2,
    ZeroZero = 7'd4,
    ZeroOne = 7'd8
    One = 7'd16,
    OneZero = 7'd32
    OneOne = 7'd64
  } state_t;
`else
  localparam logic [6:0] Start = 7'd1;
  localparam logic [6:0] Zero = 7'd2;
  localparam logic [6:0] ZeroZero = 7'd4;
  localparam logic [6:0] ZeroOne = 7'd8;
  localparam logic [6:0] One = 7'd16;
  localparam logic [6:0] OneZero = 7'd32;
  localparam logic [6:0] OneOne = 7'd64;
  typedef logic [6:0] state_t;
`endif  // USE_ENUM_STATE

  state_t state_d, state_q;
  logic [3:0] number_o_d, number_o_q;

  assign number_o = number_o_q;

  always_ff @(posedge clk_i, negedge rst_ni) begin
`ifdef FORMAL
    // SV assertions
    default clocking
      formal_clock @(posedge clk_i);
    endclocking
    default disable iff (!rst_ni);
`endif  // FORMAL
    if (!rst_ni) begin
      state_q <= Start;
      number_o_q <= '0;
    end else begin
      state_q <= state_d;
      number_o_q <= number_o_d;
    end
  end

  always_comb begin
    // default values
    state_d = state_q;
    number_o_d = number_o_q;
    unique case (state_q)
      Start: begin
        if (btn_0_i) begin
          state_d = Zero;
        end else if (btn_1_i) begin
          state_d = One;
        end
      end
      Zero: begin
        if (btn_0_i) begin
          state_d = ZeroZero;
        end else if (btn_1_i) begin
          state_d = ZeroOne;
        end
      end
      ZeroZero: begin
        if (btn_0_i) begin
          state_d = Start;
          number_o_d = 4'd1;
        end else if (btn_1_i) begin
          state_d = Start;
          number_o_d = 4'd2;
        end
      end
      ZeroOne: begin
        if (btn_0_i) begin
          state_d = Start;
          number_o_d = 4'd3;
        end else if (btn_1_i) begin
          state_d = Start;
          number_o_d = 4'd4;
        end
      end
      One: begin
        if (btn_0_i) begin
          state_d = OneZero;
        end else if (btn_1_i) begin
          state_d = OneOne;
        end
      end
      OneZero: begin
        if (btn_0_i) begin
          state_d = Start;
          number_o_d = 4'd5;
        end else if (btn_1_i) begin
          state_d = Start;
          number_o_d = 4'd6;
        end
      end
      OneOne: begin
        if (btn_0_i) begin
          state_d = Start;
          number_o_d = 4'd7;
        end else if (btn_1_i) begin
          state_d = Start;
          number_o_d = 4'd8;
        end
      end
      default: begin
        state_d = Start;
      end
    endcase
  end
endmodule
