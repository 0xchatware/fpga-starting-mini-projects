import cocotb
from cocotb.triggers import Timer
import os
from pathlib import Path
import sys

from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,ReadWrite,with_timeout, First, Join
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

from random import getrandbits

async def reset(rst,clk):
    """ Helper function to issue a reset signal to our module """
    rst.value = 1
    await ClockCycles(clk,3)
    rst.value = 0
    await ClockCycles(clk,2)

async def drive_data(dut,data_byte,control_bits,ve_bit):
    """ submit a set of data values as input, then wait a clock cycle for them to stay there. """
    dut.i_data.value = data_byte
    dut.i_control.value = control_bits
    dut.i_ve.value = ve_bit
    await FallingEdge(dut.i_clk)
    
async def count_bits(n):
    bits = 0
    while n:
        bits += 1
        n &= n - 1
    return bits
    
async def tm_choice(data):
    qm_1 = data & 0b1
    qm_2 = data & 0b1
    for i in range(1, 8):
        qm_1 |= (data & (1 << i)) ^ (qm_1 & (1 << i - 1)) << 1
        qm_1 |= (1 << 8)
        qm_2 |= ((data & (1 << i)) ^ (qm_2 & (1 << i - 1)) << 1) ^ (1 << i)
        
    num_ones = await count_bits(data)
    if (num_ones > 4 or (num_ones == 4 and (data & 1 == 0))):
        qm = qm_2
    else:
        qm = qm_1
    return qm
    
@cocotb.test()
async def test_tmds(dut):
    cocotb.start_soon(Clock(dut.i_clk, 10, units="ns").start())
    # set all inputs to 0
    dut.i_data.value = 0
    dut.i_control.value = 0
    dut.i_ve.value = 0
    # use helper function to assert reset signal
    await reset(dut.i_rst,dut.i_clk)

    print("First Test!")
    tally = 0
    for data in range(0b1111_1111 + 1):
        await drive_data(dut, data, 0b00, 1)
        qm = await tm_choice(data)
        num_ones = await count_bits(qm & 0xFF)
        tmds = qm
        if (tally < 0 and num_ones < 4) or (tally > 0 and num_ones > 4):
            tmds = (1 << 9) | (qm & (1 << 8)) | qm ^ 0b1111_1111
        num_ones = await count_bits(tmds)
        num_zeros = 10 - num_ones
        tally += num_ones - num_zeros
        assert dut.o_tmds.value.integer == tmds, f"For {bin(data)}.\n\t\tCurrent Tally is {dut.r_tally.value}.\n\t\tNum of Ones is {dut.v_num_ones.value}."
    
    print("Second Test!")
    control = 0
    for data in range(0b1111_1111 + 1):
        await drive_data(dut, data, control, 1)
        qm = await tm_choice(data)
        num_ones = await count_bits(qm & 0xFF)
        tmds = qm
        if (tally < 0 and num_ones < 4) or (tally > 0 and num_ones > 4):
            tmds = (1 << 9) | (qm & (1 << 8)) | qm ^ 0b1111_1111
        num_ones = await count_bits(tmds)
        num_zeros = 10 - num_ones
        tally += num_ones - num_zeros
        assert dut.o_tmds.value.integer == tmds, f"For {bin(data)}.\n\t\tCurrent Tally is {dut.r_tally.value}.\n\t\tNum of Ones is {dut.v_num_ones.value}."
        control = control+1 if control < 3 else 0
        
    print("Third Test!")
    for data in range(0b1111_1111 + 1):
        await drive_data(dut, data, control, 0)
        tmds = 0
        match control:
            case 0: tmds = 0b1101010100
            case 1: tmds = 0b0010101011
            case 2: tmds = 0b0101010100
            case 3: tmds = 0b1010101011
        assert dut.o_tmds.value.integer == tmds, f"For {bin(data)}."
        control = control + 1 if control < 3 else 0
    
def test_tmds_runner():
    """Run the TMDS runner. Boilerplate code"""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "tb" / "sim"))
    sources = [proj_path / "rtl" / "TMDS_Encoder.sv", proj_path / "rtl" / "TM_Choice.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="TMDS_Encoder",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="TMDS_Encoder",
        test_module="test_tmds",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    test_tmds_runner()
