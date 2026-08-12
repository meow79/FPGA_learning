import math
import os
import random
import struct

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray
from cocotb_tools.runner import get_runner


class Convolution1DHelper:

    def __init__(self, dut):
        self.dut = dut
        self.FILTER_SIZE = int(os.getenv("FILTER_SIZE"))
        self.FILTER = list(map(float, os.getenv("FILTER").split(',')))

        self.input_arr = []
        self.res = []

        self.input_arr_is_over = 0
        self.cnt_cycles_until_conv_end = 0
        self.conv_is_over = 0

    async def initialize_rst(self):
        self.dut.aresetn.value = 0
        await ClockCycles(self.dut.clk, 2)
        self.dut.aresetn.value = 1

    async def setup(self):
        self.dut.s_valid.value = 0
        self.dut.m_ready.value = random.randint(0, 1)

    def generate_rnd_input(self):
        self.dut.s_valid.value = random.randint(0, 1)
        self.dut.s_data.value = LogicArray([random.randint(0, 1) for _ in range(8)])
        self.dut.s_last.value = 1 if random.random() < 0.1 else 0

        self.dut.m_ready.value = random.randint(0, 1)

    def model_convolution_1d(self):
        if self.conv_is_over and self.dut.m_ready.value:
            self.conv_is_over = 0
            self.input_arr = []

        if self.input_arr_is_over and self.dut.s_ready_from_windowed.value:
            self.cnt_cycles_until_conv_end -= 1
            if self.cnt_cycles_until_conv_end == 0:
                self.conv_is_over = 1
                self.input_arr_is_over = 0
        elif self.dut.s_valid.value and self.dut.s_ready.value:
            self.input_arr += [int(self.dut.s_data.value)]
            if self.dut.s_last.value:
                self.input_arr_is_over = 1
                self.cnt_cycles_until_conv_end = self.FILTER_SIZE // 2
                self.res = self.convolve1d(self.input_arr, filter=self.FILTER)

    def convolve1d(self, input, filter):
        filter_len = len(filter)
        padding_size = filter_len // 2
        input_with_padding = ([0] * padding_size) + input +  ([0] * padding_size)

        res = [0] * len(input)
        for i in range(0, len(input)):
            k = 0
            for j in input_with_padding[i:i + padding_size * 2 + 1]:
                mul_res = math.floor(j * filter[k] + 0.5)
                res[i] += (mul_res if mul_res > 0 else 0)
                if res[i] > 255:
                    res[i] = 255
                    break
                k += 1
        return res

@cocotb.test()
async def convolution_1d_test(dut):
    NOfIterations = 10000

    checks_cnt = 0

    clock = Clock(dut.clk, 10, unit="ns")
    helper = Convolution1DHelper(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)
    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)

    dut_res = []
    for _ in range(NOfIterations):
        helper.model_convolution_1d()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if dut.m_valid.value and dut.m_ready.value:
            dut_res += [int(dut.m_data.value)]

        if helper.conv_is_over:
            checks_cnt += 1

            assert dut.m_valid.value, f"Incorrect m_valid. Expected: 1, actual: {dut.m_valid.value}"
            assert dut.m_last.value, f"Incorrect m_last. Expected: 1, actual: {dut.m_last.value}"

            if (dut.m_ready.value):
                actual_res = dut_res
                dut_res = []
            else:
                actual_res = dut_res + [int(dut.m_data.value)]
            assert (
                helper.res == actual_res
            ), f"Incorrect result of convoluition. Expected: {helper.res}, actual: {actual_res}"
        else:
            assert not dut.m_last.value, f"Incorrect m_last. Expected: 0, actual: {dut.m_last.value}"

    assert checks_cnt > 0, f"No checks were made"
    print(f"{checks_cnt} checks were made")


def run_test(filter):
    print(f"Filter = {filter}")
    sim = "icarus"
    sources = ["../../07-bus/05_convolution_1d/convolution_1d.sv",
               "../../07-bus/04-windowed/windowed.sv",
               "../../05-types/04_scalar_product/scalar_product_float_to_byte.sv",
               "../../05-types/03_float_mult_byte_extended/float_mult_byte.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="convolution_1d",
        parameters={"FILTER_SIZE": len(filter),"FILTER_OF_FLOATS": int(float_list_to_bits_str(filter), 2)},
        timescale=("1ns", "1ps"),
        always=True
    )

    runner.test(
        hdl_toplevel="convolution_1d",
        test_module="convolution_1d_test",
        extra_env={"FILTER_SIZE": str(len(filter)), "FILTER": ','.join(map(str, filter))}
    )

def float_list_to_bits_str(float_list):
    res = ""
    for float_num in float_list:
        int_from_float = struct.unpack("I", struct.pack("f", float_num))[0]
        res = f"{int_from_float:032b}" + res
    return res

if __name__ == "__main__":
    run_test(filter=[0.33, 0.33, 0.33])
    run_test(filter=[-1.0, 2.0, -1.0])
    run_test(filter=[0.1, 0.2, 0.9, 0.2, 0.1])
