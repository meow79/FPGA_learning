module serial_1bit_adder(
  input logic clk,
  input logic aresetn,

  // Input from master 1
  input logic s_valid_1,
  output logic s_ready_1,
  input logic s_data_1,
  input logic s_is_last_bit_1,

  // Input from master 2
  input logic s_valid_2,
  output logic s_ready_2,
  input logic s_data_2,
  input logic s_is_last_bit_2,

  // Output to slave
  output logic m_valid,
  input logic m_ready,
  output logic m_data,
  output logic m_is_last_bit
);

  logic carry_ff;
  logic bit_1_ff, bit_2_ff;
  logic valid_1_ff, valid_2_ff;
  logic num_1_is_over, num_2_is_over;

  logic carry;
  always_comb begin
    carry = (bit_1_ff & bit_2_ff) | (bit_1_ff & carry_ff) | (bit_2_ff & carry_ff);
  end

  // Data logic
  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      bit_1_ff <= '0;
      bit_2_ff <= '0;
      carry_ff <= '0;
    end else begin
      if (num_1_is_over) bit_1_ff <= '0;
      if (num_2_is_over) bit_2_ff <= '0;

      if (s_valid_1 && s_ready_1) begin
        bit_1_ff <= s_data_1;
      end
      if (s_valid_2 && s_ready_2) begin
        bit_2_ff <= s_data_2;
      end

      if (m_valid && m_ready) begin
        carry_ff <= carry;
      end
    end
  end

  logic nums_are_over_but_last_carry_is_1;
  always_comb begin
    nums_are_over_but_last_carry_is_1 = num_1_is_over && num_2_is_over && carry;
  end

  // Control signals logic
  always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      valid_1_ff <= '0;
      valid_2_ff <= '0;
      num_1_is_over <= '0;
      num_2_is_over <= '0;
    end else begin
      if (m_valid && m_ready) begin
        valid_1_ff <= '0;
        valid_2_ff <= '0;
        if (nums_are_over_but_last_carry_is_1) begin // Nulls at both inputs
          valid_1_ff <= '1;
          valid_2_ff <= '1;
        end else begin
          if (num_1_is_over && !num_2_is_over) valid_1_ff <= '1; // Nulls at input 1
          else if (num_2_is_over && !num_1_is_over) valid_2_ff <= '1; // Nulls at input 2
          // Else both numbers are over and carry is 0. Nothing to do
        end

        if (m_is_last_bit) begin
          num_1_is_over <= '0;
          num_2_is_over <= '0;
        end
      end

      if (s_valid_1 && s_ready_1) begin
        valid_1_ff <= '1;
        if (s_is_last_bit_1) num_1_is_over <= '1;
      end
      if (s_valid_2 && s_ready_2) begin
        valid_2_ff <= '1;
        if (s_is_last_bit_2) num_2_is_over <= '1;
      end
    end
  end

  // Outputs logic
  always_comb begin
    m_valid = valid_1_ff && valid_2_ff;
    s_ready_1 =
      !(m_valid && !m_ready) && !(num_1_is_over && !num_2_is_over) &&
      !nums_are_over_but_last_carry_is_1;
    s_ready_2 =
      !(m_valid && !m_ready) && !(num_2_is_over && !num_1_is_over) &&
      !nums_are_over_but_last_carry_is_1;
    m_data = bit_1_ff + bit_2_ff + carry_ff;
    m_is_last_bit = (num_1_is_over && num_2_is_over && !carry);
  end
endmodule
