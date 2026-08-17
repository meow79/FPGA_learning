import ast
import math
import os
import random
import struct

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray
from cocotb.utils import get_sim_time
from cocotb_tools.runner import get_runner


class HelperConvolution2D:
    def __init__(self, dut):
        self.dut = dut
        self.FILTER = ast.literal_eval(os.getenv("FILTER"))
        self.FILTER_SIZE = len(self.FILTER)
        self.input_arr = [[] for _ in range(self.FILTER_SIZE)]
        self.res = []
        self.input_is_over = 0

    async def initialize_rst(self):
        self.dut.aresetn.value = 0
        await ClockCycles(self.dut.clk, num_cycles=2)
        self.dut.aresetn.value = 1

    async def setup(self):
        self.dut.weight_valid.value = 0

        self.dut.s_cur_bytes_of_strings_valid.value = 0
        self.dut.m_new_str_byte_ready.value = random.randint(0, 1)

    async def initialize_filter(self):
        for i in range(self.FILTER_SIZE):
            for j in range(self.FILTER_SIZE):
                self.dut.weight_valid.value = 1
                self.dut.weight_row.value = i
                self.dut.weight_col.value = j
                self.dut.weight.value = float_to_bits_str(self.FILTER[i][j])
                await RisingEdge(self.dut.clk)
        self.dut.weight_valid.value = 0
        await RisingEdge(self.dut.clk)

    def generate_rnd_input(self):
        self.dut.s_cur_bytes_of_strings_valid.value = random.randint(0, 1)
        self.dut.s_cur_bytes_of_strings.value = LogicArray(
            [random.randint(0, 1) for _ in range(self.FILTER_SIZE * 8)]
        )
        self.dut.s_cur_bytes_of_strings_last.value = 1 if random.random() < 0.1 else 0

        self.dut.m_new_str_byte_ready.value = random.randint(0, 1)

    def model_convolution_2d(self):
        if (self.dut.m_new_str_byte_valid.value and self.dut.m_new_str_byte_ready.value
            and self.dut.m_new_str_byte_last.value):
            self.input_is_over = 0
            self.input_arr = [[] for _ in range(self.FILTER_SIZE)]

        if self.dut.s_cur_bytes_of_strings_valid.value and self.dut.s_cur_bytes_of_strings_ready.value:
            for i in range(0, self.FILTER_SIZE):
                self.input_arr[i] += [int(self.dut.s_cur_bytes_of_strings.value[i*8+7:i*8])]

            if self.dut.s_cur_bytes_of_strings_last.value:
                self.res = self.convolve2d(self.input_arr, filter=self.FILTER)
                self.input_is_over = 1

    def convolve2d(self, input, filter):
        output_len = len(input[0])
        res = [0] * output_len
        conv1d_results = [[] for _ in range(len(filter))]

        for i in range(len(filter)):
            conv1d_results[i] = self.convolve1d(input[i], filter=filter[i])

        for i in range(output_len):
            for j in range(len(filter)):
                res[i] += conv1d_results[j][i]
                if res[i] > 255:
                    res[i] = 255
                    break
        return res

    def convolve1d(self, input, filter):
        res = [0] * len(input)
        padding_size = len(filter) // 2
        input_with_padding = [0] * padding_size + input + [0] * padding_size

        for i in range(0, len(input)):
            for j in range(0, len(filter)):
                mul_res = math.floor(input_with_padding[i+j] * filter[j] + 0.5)
                if mul_res > 255:
                    mul_res = 255
                elif mul_res < 0:
                    mul_res = 0

                res[i] += mul_res
                if res[i] > 255:
                    res[i] = 255
                    break
        return res

@cocotb.test()
async def convolution_2d_test(dut):
    NOfIterations = 10_000

    checks_cnt = 0

    clock = Clock(dut.clk, period=10, unit="ns")
    helper = HelperConvolution2D(dut)
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk)
    cocotb.start_soon(helper.initialize_rst())
    cocotb.start_soon(helper.setup())

    await RisingEdge(dut.aresetn)
    await helper.initialize_filter()

    dut_res = []
    prev_m_valid = prev_m_ready = prev_m_data = prev_m_last = 0
    for _ in range(NOfIterations):
        helper.model_convolution_2d()
        helper.generate_rnd_input()

        await RisingEdge(dut.clk)
        if dut.m_new_str_byte_valid.value and dut.m_new_str_byte_ready.value:
            dut_res += [int(dut.m_new_str_byte.value)]

        if (dut.m_new_str_byte_valid.value and dut.m_new_str_byte_ready.value
            and dut.m_new_str_byte_last.value):
            checks_cnt += 1

            assert (
                helper.input_is_over
            ), f"{get_sim_time('ns')} Input is not over, but m_new_str_byte_valid = 1 and m_new_str_byte_last = 1"
            assert (
                helper.res == dut_res
            ), f"{get_sim_time('ns')} Incorrect result of convolution. Expected: {helper.res}, actual: {dut_res}"
            dut_res = []

        if helper.input_is_over:
            assert (
                not dut.s_cur_bytes_of_strings_ready.value
            ), f"Current input stream has ended and is not accepted yet, but s_cur_bytes_of_strings_ready = 1"

        if prev_m_valid and not prev_m_ready:
            assert (
                dut.m_new_str_byte_valid.value
            ), f"m_new_str_byte_valid changed from 1 to 0 while data not accepted"
            assert (
                dut.m_new_str_byte.value == prev_m_data
            ), f"m_new_str_byte changed while not accepted"
            assert (
                dut.m_new_str_byte_last.value == prev_m_last
            ), f"m_new_str_byte_last changed while data not accepted"

        prev_m_valid = dut.m_new_str_byte_valid.value
        prev_m_ready = dut.m_new_str_byte_ready.value
        prev_m_data = dut.m_new_str_byte.value
        prev_m_last = dut.m_new_str_byte_last.value

    assert checks_cnt > 0, f"No checks were made"
    print(f"{checks_cnt} checks were made")


def run_test(filter):
    pretty_str_filter = '\n'.join(['\t'.join([str(el) for el in row]) for row in filter])
    print(f"Filter:\n{pretty_str_filter}")
    sources = ["convolution_2d.sv",
               "../../07-bus/05_convolution_1d/convolution_1d.sv",
               "../../07-bus/04-windowed/windowed.sv",
               "../../05-types/04_scalar_product/scalar_product_float_to_byte.sv",
               "../../05-types/03_float_mult_byte_extended/float_mult_byte.sv"]

    runner = get_runner(simulator_name="icarus")
    runner.build(
        sources=sources,
        parameters={"FILTER_SIZE": str(len(filter))},
        hdl_toplevel="convolution_2d",
        timescale=(("1ns", "1ps")),
        always=True
    )

    runner.test(
        hdl_toplevel="convolution_2d",
        test_module="convolution_2d_test",
        extra_env={"FILTER": str(filter)}
    )

def float_to_bits_str(float_num):
    int_from_float = struct.unpack("I", struct.pack("f", float_num))[0]
    return f"{int_from_float:032b}"

if __name__ == "__main__":
    run_test(
        filter=[[1/9, 1/9, 1/9],
                [1/9, 1/9, 1/9],
                [1/9, 1/9, 1/9]]
    )
    run_test(
        filter=[[-1, -1, -1],
                [-1, 8, -1],
                [-1, -1, -1]]
    )
    run_test(
        filter=[[0.1, 0.2, 0.3],
                [0.25, 0.003, 0.4],
                [-2, 0.03, 0.1]]
    )
    run_test(
        filter=[[float(random.random()) for _ in range(5)] for _ in range(5)]
    )
