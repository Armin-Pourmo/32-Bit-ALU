# Testbench for tt_um_armin_pourmo_alu32

This is the cocotb testbench for the Tiny Tapeout submission of the 32-bit
ALU. It drives the chip pins directly through the byte-addressable register
protocol documented in [../src/tt_um_armin_pourmo_alu32.sv](../src/tt_um_armin_pourmo_alu32.sv)
and checks `result`/flags against Python-computed expected values.
See [tt_um_armin_pourmo_alu32.sv](../src/tt_um_armin_pourmo_alu32.sv) for the
register map, and [test.py](test.py) for the test cases themselves.

For background on cocotb and the Tiny Tapeout test flow in general, see
[the website](https://tinytapeout.com/hdl/testing/).

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden the project and copy
`../runs/wokwi/results/final/verilog/gl/tt_um_armin_pourmo_alu32.v` to
`gate_level_netlist.v`. Then run:

```sh
make -B GATES=yes
```

If you wish to save the waveform in VCD format instead of FST format, edit
tb.v to use `$dumpfile("tb.vcd");` and then run:

```sh
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave

```sh
gtkwave tb.fst tb.gtkw
```

Using Surfer

```sh
surfer tb.fst
```
