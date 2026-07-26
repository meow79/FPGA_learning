import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.types import LogicArray
import random

class HelperPairwise:
    current_pair = [0] * 2
    valid_elements_cnt = 0
    out_valid = 0

    def __init__(self, dut):
        self.dut = dut

    async def initialize_rst(self):
        self.dut.aresetn.value = 0
        await ClockCycles(self.dut.clk, 2)
        self.dut.aresetn.value = 1

    async def setup(self):
        self.dut.s_valid.value = 0
        self.dut.m_ready.value = random.randint(0, 1)

    def generate_rnd_input(self):
        self.dut.s_valid.value = random.randint(0, 1)
        self.dut.s_data.value = random.randint(0, 1)
        self.dut.m_ready.value = random.randint(0, 1)

    def model_pairwise(self):
        if not self.dut.aresetn.value:
            self.current_pair = [0] * 2
            self.valid_elements_cnt = 0
            self.out_valid = 0
        else:
            if self.out_valid and self.dut.m_ready.value:
                self.out_valid = 0

            if self.dut.s_valid.value and self.dut.s_ready.value:
                self.current_pair = [int(self.dut.s_data.value)] + [self.current_pair[0]]
                if self.valid_elements_cnt < 2:
                    self.valid_elements_cnt += 1
                if self.valid_elements_cnt == 2:
                    self.out_valid = 1

@cocotb.test()
async def pairwise_test(dut):
    NOfIterations = 1000

    checks_cnt = 0

    clock = Clock(dut.clk, 10, unit="ns")
    helper = HelperPairwise(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)
    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)
    for _ in range (NOfIterations):
        helper.model_pairwise()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if helper.out_valid:
            checks_cnt += 1
            assert dut.m_valid.value, f"Incorrect m_valid. Expected: 1, actual: {dut.m_valid.value}"
            assert (
                dut.m_data.value == LogicArray(helper.current_pair)
            ), f"Incorrect m_data. Expected: {LogicArray(helper.current_pair)}, actual: {dut.m_data.value}"
        else:
            assert not dut.m_valid.value, f"Incorrect m_valid. Expected 0, actual: {dut.m_valid.value}"

    assert (checks_cnt > 0), f"helper.out_valid was always 0!"
    print(f"{checks_cnt} checks were made")
