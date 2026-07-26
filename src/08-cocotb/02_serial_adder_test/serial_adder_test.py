import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock
import random

class HelperSerialAdder:
    out_bit = 0
    is_last_bit = 0
    out_valid = 0

    carry = 0
    sum_res = 0
    valid_1 = valid_2 = 0
    num_1_is_over = num_2_is_over = 0

    def __init__(self, dut):
        self.dut = dut

    async def initialize_rst(self):
        self.dut.aresetn.value = 0
        await ClockCycles(self.dut.clk, 2)
        self.dut.aresetn.value = 1

    async def setup(self):
        self.dut.s_valid_1.value = 0
        self.dut.s_valid_2.value = 0
        self.dut.m_ready.value = random.randint(0, 1)

    def generate_rnd_input(self):
        self.dut.s_valid_1.value = random.randint(0, 1)
        self.dut.s_data_1.value = random.randint(0, 1)
        self.dut.s_is_last_bit_1.value = 1 if random.random() < 0.1 else 0

        self.dut.s_valid_2.value = random.randint(0, 1)
        self.dut.s_data_2.value = random.randint(0, 1)
        self.dut.s_is_last_bit_2.value = 1 if random.random() < 0.1 else 0

        self.dut.m_ready.value = random.randint(0, 1)

    def model_serial_adder(self):
        if not self.dut.aresetn.value:
            self.out_bit = 0
            self.is_last_bit = 0
            self.out_valid = 0
            self.carry = 0
            self.sum_res = 0
            self.valid_1 = self.valid_2 = 0
            self.num_1_is_over = self.num_2_is_over = 0
        else:
            if self.out_valid and self.dut.m_ready.value:
                self.carry = int((self.sum_res + self.carry) > 1)
                self.sum_res = 0
                self.out_valid = 0
                self.valid_1 = self.valid_2 = 0
                if self.is_last_bit:
                    self.num_1_is_over = self.num_2_is_over = 0
                    self.is_last_bit = 0

            if self.dut.s_valid_1.value and self.dut.s_ready_1.value:
                self.sum_res += int(self.dut.s_data_1.value)
                self.valid_1 = 1
                if (self.dut.s_is_last_bit_1.value):
                    self.num_1_is_over = 1
            if self.dut.s_valid_2.value and self.dut.s_ready_2.value:
                self.sum_res += int(self.dut.s_data_2.value)
                self.valid_2 = 1
                if (self.dut.s_is_last_bit_2.value):
                    self.num_2_is_over = 1

            if (self.valid_1 or self.num_1_is_over) and (self.valid_2 or self.num_2_is_over):
                self.out_valid = 1
                sum_with_carry = self.sum_res + self.carry
                self.out_bit = int((sum_with_carry) == 1 or (sum_with_carry) == 3)
                self.is_last_bit = int(self.num_1_is_over and self.num_2_is_over and (sum_with_carry) < 2)


@cocotb.test()
async def serial_1bit_adder_test(dut):
    NOfIterations = 10000
    checks_cnt = 0

    clock = Clock(dut.clk, 10, unit="ns")
    helper = HelperSerialAdder(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)

    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)
    for _ in range (NOfIterations):
        helper.model_serial_adder()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if helper.out_valid:
            checks_cnt += 1
            assert dut.m_valid.value, f"Incorrect m_valid. Expected: 1, actual: {dut.m_valid.value}"
            assert (
                helper.out_bit == dut.m_data.value
            ), f"Incorrect m_data. Expected: {helper.out_bit}, actual: {dut.m_data.value}"
            assert (
                helper.is_last_bit == dut.m_is_last_bit.value
            ), f"Incorrect m_is_last_bit. Expected: {helper.is_last_bit}, actual: {dut.m_is_last_bit.value}"
        else:
            assert not dut.m_valid.value, f"Incorrect m_valid. Expected: 0, actual: {dut.m_valid.value}"

    assert checks_cnt > 0, "checks were not made!"
    print(f"{checks_cnt} checks were made")
