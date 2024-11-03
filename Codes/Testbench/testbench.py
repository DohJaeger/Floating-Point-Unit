import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def basic_count(dut):
    #generate clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    #reset dut
    dut.reset.value = 1

    #hold reset for 2 clks

    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    #run for 50ns, with an assertion
    for cnt in range(50):
        await RisingEdge(dut.clk)
        dut_cnt = dut.count.value
        predicted_value = cnt % 16
        assert dut_cnt == predicted_value, \
            "error %s != %s" % (str(dur.count.value), predicted_value)