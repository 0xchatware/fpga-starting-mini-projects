# Mini FPGA Project made for PYNQ-Z2

This is a collection of FPGA projects that I implemented in order to aquire basic FPGA skills like: 
- Writing **RTL** modules with **System Verilog**, **Verilog**, and **VHDL**;
- Writing **Testbenches** with **System Verilog**, and **CocoTB**;
- Getting familiar with **TCL commands** for **constraints file**, adding **delays**, and **scripting**;
- Getting familiar of using **version control** with FPGA projects;
- Getting a better understanding of **Timing Analysis**.

## Contents

## Directory Structure

```
fpga-starting-mini-projects/
    rebuild.tcl   - TCL script created by Vivado.
    rtl/          - Verilog (or VHDL) source code.
    tb/           - Verilog (or VHDL, CocoTB with Python) testbenches.
    cons/         - Constraint files.
    ip/           - Xilinx IP.
    rsc/          - Memory and header files.
    bit/          - Generated bitstream files.
```
### Building

Use this command to create the Vivado Project :
```bash
vivado -source rebuild.tcl
```

## Projects

All projects are in the same source files. 

Projects are listed in creation order.

In order to start Synthesis, Implementation and Bitstream Generation for the right Project, be sure to select the rigth constraint set and top file.

| Projects                           | Top Module                      | Constraint Set                |
|------------------------------------|---------------------------------|-------------------------------|
| Blinking Led at 1 Hz               | Blinking_Led.vhd                | constrs_blinking_led          |
| Counter with Seven Segments        | Counter_7Segment.vhd            | constrs_counter_7segment      |
| Square Pattern with HDMI at 480p   | Square_Pattern_Hdmi_480p_Top.sv | constrs_hdmi                  |
| Square Pattern with HDMI at 720p   | Square_Pattern_Hdmi_720p_Top.sv | constrs_hdmi_720p             |
| Pong Game with HDMI at 720p        | Pong_720p_Top.sv                | constrs_pong_720p             |
| Text Overlay with HDMI at 720p     | Text_Overlay_720p_Top.sv        | constrs_text_overlay_720p     |
| Text Patterns with HDMI at 720p    | Test_Pattern_720p_Top.sv        | constrs_test_pattern_720p     |
| CORDIC Algorithm with HDMI at 720p | CORDIC_Algorithm_HDMI_Top.sv    | constrs_cordic_algorithm_hdmi |

### Blinking Led at 1 Hz

Using a clock enable for making a LED blink 1 second at a time.

### Counter with Seven Segments

Using FPGAs PMOD and connect it to LEDs to mimick a SevenSegment. 

Clock enabled logic of the previous project helped building the counter.

### Patterns with HDMI at 480p

Displayed different patterns with the help of an HDMI module I made.

### Square Pattern with HDMI at 720p

Same as [Patterns with HDMI at 480p](#patterns-with-hdmi-at-480p), but with a resolution of 720p.

### Pong Game with HDMI at 720p

A simple pong game with a bot

### Text Overlay with HDMI at 720p

### Text Patterns with HDMI at 720p

### CORDIC Algorithm with HDMI at 720p

## Resources

- How to setup Vivado with git: https://github.com/jhallen/vivado_setup
