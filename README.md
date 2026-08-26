![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# 32-bit ALU — Tiny Tapeout (TTIHP26b)

A 32-bit ALU (ADD/SUB with flags, AND/OR/XOR/NOR, LSL/LSR/ASR) submitted
to the [Tiny Tapeout](https://tinytapeout.com) TTIHP26b shuttle (IHP
SG13G2 130nm).

- [Read the project documentation](docs/info.md)

## Layout

- [src/](src/) — the ALU core (`alu.sv` and its submodules) and the
  Tiny Tapeout top-level wrapper (`tt_um_armin_pourmo_alu32.sv`) that
  exposes it through a byte-addressable register interface over the 24
  available chip I/O pins.
- [tb/](tb/) — standalone SystemVerilog testbenches for the ALU core,
  run directly with Icarus Verilog during RTL development.
- [test/](test/) — the cocotb testbench Tiny Tapeout's CI runs against
  the `tt_um_armin_pourmo_alu32` wrapper (chip-pin level, not the raw
  ALU ports).
- [info.yaml](info.yaml) — Tiny Tapeout project metadata (pinout,
  top module, source file list, tile size).

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and
cheaper than ever to get your digital and analog designs manufactured
on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)
