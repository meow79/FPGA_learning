import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray
import random

class HelperMergeParallel:
    InWidth1 = 3
    InWidth2 = 8
    OutWidth = InWidth1 + InWidth2

    valid_1 = valid_2 = False
    expected_res = [0] * OutWidth

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
        self.dut.s_data_1.value = LogicArray([random.randint(0, 1) for _ in range(self.InWidth1)])

        self.dut.s_valid_2.value = random.randint(0, 1)
        self.dut.s_data_2.value = LogicArray([random.randint(0, 1) for _ in range(self.InWidth2)])

        self.dut.m_ready.value = random.randint(0, 1)

    def model_merge_parallel(self):
        if not self.dut.aresetn.value:
            self.expected_res = [0] * self.OutWidth
            self.valid_1 = False
            self.valid_2 = False
        else:
            if self.dut.s_ready_1.value and self.dut.s_valid_1.value:
                self.expected_res[self.InWidth2:] = list(self.dut.s_data_1.value)
                self.valid_1 = True
            if self.dut.s_ready_2.value and self.dut.s_valid_2.value:
                self.expected_res[:self.InWidth2] = list(self.dut.s_data_2.value)
                self.valid_2 = True

            if self.dut.m_valid.value and self.dut.m_ready.value:
                self.valid_1 = False
                self.valid_2 = False


@cocotb.test()
async def merge_parallel_test(dut):
    NOfIterations = 1000

    clock = Clock(dut.clk, 10, unit="ns")
    helper = HelperMergeParallel(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)

    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)
    for _ in range(NOfIterations):
        helper.model_merge_parallel()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if helper.valid_1 and helper.valid_2:
            assert dut.m_valid.value, f"Incorrect m_valid. Expected: 1, actual: {dut.m_valid}"
            assert(
                LogicArray(helper.expected_res) == dut.m_data.value
            ), f"Incorrect m_data. Expected: {LogicArray(helper.expected_res)}\n\
                 Actual: {dut.m_data.value}"
