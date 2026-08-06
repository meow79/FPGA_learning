import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.types import LogicArray
import random

class HelperWindowed:
    DataWidth = 8
    WindowSize = 3

    current_window = [0] * WindowSize
    valid_elements_cnt = 0
    out_valid = 0
    out_last = 0

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
        self.dut.s_data.value = LogicArray([random.randint(0, 1) for _ in range(self.DataWidth)])
        self.dut.s_last.value = 1 if random.random() < 0.1 else 0
        self.dut.m_ready.value = random.randint(0, 1)

    def model_windowed(self):
        if not self.dut.aresetn.value:
            self.current_window = [0] * self.WindowSize
            self.valid_elements_cnt = 0
            self.out_valid = 0
            self.out_last = 0
        else:
            if self.out_valid and self.dut.m_ready.value:
                self.out_valid = 0
                if self.out_last:
                    self.current_window = [0] * self.WindowSize
                    self.valid_elements_cnt = 0
                    self.out_last = 0

            if self.dut.s_valid.value and self.dut.s_ready.value:
                self.current_window = [int(self.dut.s_data.value)] + self.current_window[0:self.WindowSize-1]
                if self.valid_elements_cnt < self.WindowSize:
                    self.valid_elements_cnt += 1
                if self.valid_elements_cnt == self.WindowSize:
                    self.out_valid = 1

                if self.dut.s_last.value:
                    self.out_last = 1

@cocotb.test()
async def windowed_test(dut):
    NOfIterations = 10000

    checks_cnt = 0

    clock = Clock(dut.clk, 10, unit="ns")
    helper = HelperWindowed(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)
    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)
    for _ in range (NOfIterations):
        helper.model_windowed()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if helper.out_valid:
            checks_cnt += 1
            expected_out = LogicArray(''.join([
                f"{num:0{helper.DataWidth}b}" for num in helper.current_window
            ]))

            assert dut.m_valid.value, f"Incorrect m_valid. Expected: 1, actual: {dut.m_valid.value}"
            assert (
                dut.m_data.value == expected_out
            ), f"Incorrect m_data. Expected: {expected_out}, actual: {dut.m_data.value}"
            assert (
                dut.m_last.value == helper.out_last
            ), f"Incorrect m_last. Expected: {helper.out_last}, actual: {dut.m_last.value}"
        else:
            assert not dut.m_valid.value, f"Incorrect m_valid. Expected: 0, actual: {dut.m_valid.value}"

    assert (checks_cnt > 0), "helper.out_valid is always 0!"
    print(f"{checks_cnt} checks were made")
