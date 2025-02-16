import cocotb
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def test_addition(dut):
    """Test the addition operation of the FPU"""
    # Set up logging for better debug visibility
    dut._log.info("Starting addition test for FPU")

    # Initialize inputs and apply clock
    dut.A.value = 0  # Reset input A
    dut.B.value = 0  # Reset input B
    dut.opcode.value = 0  # Set opcode to addition (assuming 0 is addition)
    await Timer(5, units='ns')  # Short delay before main operation

    # Set test values for inputs (in binary format)
    # 1.0 in IEEE 754 binary representation is: 00111111100000000000000000000000
    # 2.0 in IEEE 754 binary representation is: 01000000000000000000000000000000
    dut.A.value = 0b00111111100000000000000000000000  # Binary for 1.0
    dut.B.value = 0b01000000000000000000000000000000  # Binary for 2.0
    dut.opcode.value = 0       # Set opcode for addition

    # Wait for operation to complete and output to stabilize
    await Timer(50, units='ns')

    # Check output validity
    if 'x' in str(dut.O.value) or 'z' in str(dut.O.value):
        dut._log.error(f"Output O contains undefined values: {dut.O.value}")
        assert False, "Output contains unresolved 'x' or 'z' bits."

    # Expected result for 1.0 + 2.0 = 3.0 in IEEE 754 binary
    expected_result = 0b01000000010000000000000000000000  # Binary for 3.0

    # Validate result
    assert dut.O.value == expected_result, (
        f"Addition result mismatch: got {hex(dut.O.value)}, "
        f"expected {hex(expected_result)}"
    )
    
    dut._log.info("Addition test completed successfully")
