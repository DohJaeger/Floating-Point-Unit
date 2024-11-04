#test_fpu.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import struct

#convert between float and IEEE 754 single precision binary format
def float_to_bin(num):
    """Convert a float to binary (IEEE 754 single precision)."""
    return struct.unpack('>I', struct.pack('>f', num))[0]

def bin_to_float(binary):
    """Convert binary (IEEE 754 single precision) to float."""
    return struct.unpack('>f', struct.pack('>I', binary))[0]

async def reset_dut(dut):
    """Reset the DUT."""
    dut.clk.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0
    await RisingEdge(dut.clk)

@cocotb.test()
async def test_addition(dut):
    """Test addition operation on FPU."""
    clock = Clock(dut.clk, 10, units="ns")  # 10 ns clock period
    cocotb.fork(clock.start())

    await reset_dut(dut)
    
    #Test cases for addition
    test_cases = [
        (1.5, 2.5),
        (0.0, 3.5),
        (-2.75, 2.75),
        (1e20, 1e20),  # Large number addition
        (float('inf'), 1.0),  # Infinity + finite number
    ]
    
    for a, b in test_cases:
        expected = a + b
        dut.A.value = float_to_bin(a)
        dut.B.value = float_to_bin(b)
        dut.opcode.value = 0b00  # Opcode for addition

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        result = bin_to_float(dut.O.value.integer)
        tolerance = 1e-5  # Allowable error margin for floating-point comparisons

        assert abs(result - expected) < tolerance, f"Addition failed for {a} + {b}: expected {expected}, got {result}"

@cocotb.test()
async def test_subtraction(dut):
    """Test subtraction operation on FPU."""
    await reset_dut(dut)

    #Test cases for subtraction
    test_cases = [
        (3.5, 2.5),
        (0.0, 3.5),
        (-2.75, 2.75),
        (1e20, 5e19),  # Large number subtraction
        (float('inf'), 1.0),  # Infinity - finite number
    ]

    for a, b in test_cases:
        expected = a - b
        dut.A.value = float_to_bin(a)
        dut.B.value = float_to_bin(b)
        dut.opcode.value = 0b01  # Opcode for subtraction

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        result = bin_to_float(dut.O.value.integer)
        tolerance = 1e-5  # Allowable error margin for floating-point comparisons

        assert abs(result - expected) < tolerance, f"Subtraction failed for {a} - {b}: expected {expected}, got {result}"

@cocotb.test()
async def test_multiplication(dut):
    """Test multiplication operation on FPU."""
    await reset_dut(dut)

    #Test cases for multiplication
    test_cases = [
        (1.5, 2.5),
        (0.0, 3.5),
        (-2.75, 2.75),
        (1e10, 2e10),  # Large number multiplication
        (float('inf'), 1.0),  # Infinity * finite number
    ]

    for a, b in test_cases:
        expected = a * b
        dut.A.value = float_to_bin(a)
        dut.B.value = float_to_bin(b)
        dut.opcode.value = 0b11  # Opcode for multiplication

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        result = bin_to_float(dut.O.value.integer)
        tolerance = 1e-5  # Allowable error margin for floating-point comparisons

        assert abs(result - expected) < tolerance, f"Multiplication failed for {a} * {b}: expected {expected}, got {result}"

@cocotb.test()
async def test_division(dut):
    """Test division operation on FPU."""
    await reset_dut(dut)

    #Test cases for division
    test_cases = [
        (3.5, 2.5),
        (0.0, 3.5),
        (-2.75, 2.75),
        (1e10, 2e5),  # Large number division
        (float('inf'), 1.0),  # Infinity / finite number
    ]

    for a, b in test_cases:
        if b == 0:
            expected = float('inf') if a > 0 else float('-inf')
        else:
            expected = a / b

        dut.A.value = float_to_bin(a)
        dut.B.value = float_to_bin(b)
        dut.opcode.value = 0b10  # Opcode for division

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        result = bin_to_float(dut.O.value.integer)
        tolerance = 1  # Allowable error margin for floating-point comparisons

        assert abs(result - expected) < tolerance, f"Division failed for {a} / {b}: expected {expected}, got {result}"
