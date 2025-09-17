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

In order to start Synthesis, Implementation and Bitstream Generation for the right Project, be sure to make active the rigth constraint set and set the right top file as top.

| Projects                           | Top Module                                                             | Constraint Set                                                    |
| ---------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Blinking Led at 1 Hz               | [Blinking_Led.vhd](rtl/Blinking_Led.vhd)                               | [constrs_blinking_led](cons/blinking_led_constraints.xdc)         |
| Counter with Seven Segments        | [Counter_7Segment.vhd](rtl/Counter_7Segment.vhd)                       | [constrs_counter_7segment](cons/counter_7segment_constraints.xdc) |
| Square Pattern with HDMI at 480p   | [Square_Pattern_Hdmi_480p_Top.sv](rtl/Square_Pattern_Hdmi_480p_Top.sv) | [constrs_hdmi](cons/hdmi_constraints.xdc)                         |
| Square Pattern with HDMI at 720p   | [Square_Pattern_Hdmi_720p_Top.sv](rtl/Square_Pattern_Hdmi_720p_Top.sv) | [constrs_hdmi_720p](cons/hdmi_720p_constraints.xdc)               |
| Pong Game with HDMI at 720p        | [Pong_720p_Top.sv](rtl/Pong_720p_Top.sv)                               | [constrs_pong_720p](cons/pong_720p_constraints.xdc)               |
| Text Overlay with HDMI at 720p     | [Text_Overlay_720p_Top.sv](rtl/Text_Overlay_720p_Top.sv)               | [constrs_text_overlay_720p](cons/text_overlay_720p.xdc)           |
| Text Patterns with HDMI at 720p    | [Test_Pattern_720p_Top.sv](rtl/Test_Pattern_720p_Top.sv)               | [constrs_test_pattern_720p](cons/test_pattern_constraints.xdc)    |
| CORDIC Algorithm with HDMI at 720p | [CORDIC_Algorithm_HDMI_Top.sv](rtl/CORDIC_Algorithm_HDMI_Top.sv)       | [constrs_cordic_algorithm_hdmi](cons/cordic_algorithm_hdmi.xdc)   |

### Blinking Led at 1 Hz

Using a clock enable for making a LED blink 1 second at a time.

### Counter with Seven Segments

Using FPGAs PMOD and connect it to LEDs to mimick a SevenSegment. 

Clock enabled logic of the previous project helped building the counter.

### Patterns with HDMI at 480p

Displayed different patterns with the help of an HDMI module I made.

### Square Pattern with HDMI at 720p

Displaying a white square, but with a resolution of 720p.

### Pong Game with HDMI at 720p

A simple pong game against a boot. To reset the game toggle SW1 on the FPGA.

### Text Overlay with HDMI at 720p

Displaying a character on the screen.

### Text Patterns with HDMI at 720p

Displaying a character buffer on the screen.

### CORDIC Algorithm with HDMI at 720p

Implemented all CORDIC operations with fixed values. 

Not all operations are displayed on the screen yet.

## Resources

- How to setup Vivado with git: https://github.com/jhallen/vivado_setup
