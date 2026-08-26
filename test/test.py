# SPDX-FileCopyrightText: © 2026 Armin-Pourmo
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

MASK32 = 0xFFFFFFFF

OP_AND = 0b0000
OP_OR  = 0b0001
OP_XOR = 0b0010
OP_NOR = 0b0011
OP_ADD = 0b0100
OP_SUB = 0b0101
OP_LSL = 0b0110
OP_LSR = 0b0111
OP_ASR = 0b1000

ADDR_A0 = 0x0
ADDR_B0 = 0x4
ADDR_OP = 0x8
ADDR_R0 = 0x9
ADDR_FLAGS = 0xD

FLAG_ZERO = 1 << 0
FLAG_SIGN = 1 << 1
FLAG_OVERFLOW = 1 << 2
FLAG_CARRY = 1 << 3


async def write_reg(dut, addr, data):
    dut.uio_in.value = (1 << 4) | (addr & 0xF)
    dut.ui_in.value = data & 0xFF
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    dut.ui_in.value = 0


async def read_reg(dut, addr):
    dut.uio_in.value = addr & 0xF
    await ClockCycles(dut.clk, 1)
    return int(dut.uo_out.value)


async def alu_op(dut, a, b, opcode):
    """Drive one full ALU operation through the byte-addressable register
    protocol and return (result, flags)."""
    a &= MASK32
    b &= MASK32
    for i in range(4):
        await write_reg(dut, ADDR_A0 + i, (a >> (8 * i)) & 0xFF)
    for i in range(4):
        await write_reg(dut, ADDR_B0 + i, (b >> (8 * i)) & 0xFF)
    await write_reg(dut, ADDR_OP, opcode)

    result = 0
    for i in range(4):
        byte = await read_reg(dut, ADDR_R0 + i)
        result |= byte << (8 * i)
    flags = await read_reg(dut, ADDR_FLAGS)
    return result, flags


async def reset(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)


def sign32(x):
    x &= MASK32
    return x - (1 << 32) if x & 0x80000000 else x


@cocotb.test()
async def test_reset(dut):
    """After reset, result/flags registers should read back as zero."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    for addr in range(ADDR_R0, ADDR_R0 + 4):
        assert await read_reg(dut, addr) == 0
    assert await read_reg(dut, ADDR_FLAGS) == 0


@cocotb.test()
async def test_register_readback(dut):
    """Bytes written to A/B/opcode should read back unchanged before compute."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    a = 0xDEADBEEF
    b = 0xCAFEBABE
    for i in range(4):
        await write_reg(dut, ADDR_A0 + i, (a >> (8 * i)) & 0xFF)
    for i in range(4):
        await write_reg(dut, ADDR_B0 + i, (b >> (8 * i)) & 0xFF)

    readback_a = 0
    readback_b = 0
    for i in range(4):
        readback_a |= (await read_reg(dut, ADDR_A0 + i)) << (8 * i)
        readback_b |= (await read_reg(dut, ADDR_B0 + i)) << (8 * i)
    assert readback_a == a
    assert readback_b == b


@cocotb.test()
async def test_add(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    # 0 + 0 -> zero flag set
    result, flags = await alu_op(dut, 0, 0, OP_ADD)
    assert result == 0
    assert flags & FLAG_ZERO
    assert not (flags & FLAG_CARRY)
    assert not (flags & FLAG_OVERFLOW)

    # unsigned wraparound -> carry + zero result
    result, flags = await alu_op(dut, 0xFFFFFFFF, 1, OP_ADD)
    assert result == 0
    assert flags & FLAG_ZERO
    assert flags & FLAG_CARRY

    # positive overflow: largest positive + 1 wraps to most-negative
    result, flags = await alu_op(dut, 0x7FFFFFFF, 1, OP_ADD)
    assert result == 0x80000000
    assert flags & FLAG_SIGN
    assert flags & FLAG_OVERFLOW

    random.seed(0)
    for _ in range(20):
        a = random.randint(0, MASK32)
        b = random.randint(0, MASK32)
        result, _ = await alu_op(dut, a, b, OP_ADD)
        assert result == (a + b) & MASK32


@cocotb.test()
async def test_sub(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    # a < b -> borrow (negative result, sign set, carry clear)
    result, flags = await alu_op(dut, 1, 2, OP_SUB)
    assert result == 0xFFFFFFFF
    assert flags & FLAG_SIGN
    assert not (flags & FLAG_CARRY)

    # a == b -> zero
    result, flags = await alu_op(dut, 0xDEADBEEF, 0xDEADBEEF, OP_SUB)
    assert result == 0
    assert flags & FLAG_ZERO

    random.seed(1)
    for _ in range(20):
        a = random.randint(0, MASK32)
        b = random.randint(0, MASK32)
        result, _ = await alu_op(dut, a, b, OP_SUB)
        assert result == (a - b) & MASK32


@cocotb.test()
async def test_logic_ops(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    a, b = 0xAAAAAAAA, 0x55555555
    result, _ = await alu_op(dut, a, b, OP_AND)
    assert result == (a & b)
    result, _ = await alu_op(dut, a, b, OP_OR)
    assert result == (a | b)
    result, _ = await alu_op(dut, a, b, OP_XOR)
    assert result == (a ^ b)
    result, _ = await alu_op(dut, a, b, OP_NOR)
    assert result == (~(a | b)) & MASK32

    random.seed(2)
    for _ in range(10):
        a = random.randint(0, MASK32)
        b = random.randint(0, MASK32)
        for op, fn in (
            (OP_AND, lambda x, y: x & y),
            (OP_OR, lambda x, y: x | y),
            (OP_XOR, lambda x, y: x ^ y),
            (OP_NOR, lambda x, y: ~(x | y) & MASK32),
        ):
            result, _ = await alu_op(dut, a, b, op)
            assert result == fn(a, b)


@cocotb.test()
async def test_shifts(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    await reset(dut)

    # LSL
    result, _ = await alu_op(dut, 0x00000001, 31, OP_LSL)
    assert result == 0x80000000
    result, _ = await alu_op(dut, 0xFFFFFFFF, 4, OP_LSL)
    assert result == 0xFFFFFFF0

    # LSR - zero-fill regardless of sign
    result, _ = await alu_op(dut, 0x80000000, 31, OP_LSR)
    assert result == 0x00000001
    result, _ = await alu_op(dut, 0xFFFFFFFF, 4, OP_LSR)
    assert result == 0x0FFFFFFF

    # ASR - sign-extends
    result, _ = await alu_op(dut, 0x80000000, 4, OP_ASR)
    assert result == 0xF8000000
    result, _ = await alu_op(dut, 0x7FFFFFFF, 4, OP_ASR)
    assert result == 0x07FFFFFF

    # shift by 0 is a no-op
    result, _ = await alu_op(dut, 0xDEADBEEF, 0, OP_ASR)
    assert result == 0xDEADBEEF
