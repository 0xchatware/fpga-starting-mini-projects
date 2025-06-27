`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 10:21:00 AM
// Design Name: 
// Module Name: Video_Signal_Generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Inspired code from https://projectf.io/posts/fpga-graphics/,
//                                         https://fpga.mit.edu/6205/_static/F24/assignments/hdmi/vsg/vsg_template.sv
// 
//////////////////////////////////////////////////////////////////////////////////

module Video_Signal_Generator#(
    parameter ACTIVE_H_PIXELS = 640,
    parameter H_FRONT_PORCH = 16,
    parameter H_SYNCH_WIDTH = 96,
    parameter H_BACK_PORCH = 48,
    parameter ACTIVE_LINES = 480,
    parameter V_FRONT_PORCH = 10,
    parameter V_SYNCH_WIDTH = 2,
    parameter V_BACK_PORCH = 33,
    parameter FPS = 60,
    parameter TOTAL_PIXELS = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNCH_WIDTH + H_BACK_PORCH,
    parameter TOTAL_LINES = ACTIVE_LINES + V_FRONT_PORCH + V_SYNCH_WIDTH + V_BACK_PORCH)
(
    input wire i_clk_pxl,
    input wire i_reset,
    output logic [$clog2(TOTAL_PIXELS)-1:0] o_sx,
    output logic [$clog2(TOTAL_LINES)-1:0] o_sy,
    output wire o_hsync,
    output wire o_vsync,
    output wire o_de,     // data enable
    output wire o_nf,     // is next frame
    output logic [$clog2(FPS)-1:0] o_fc // frame counter
    );
    
    assign o_hsync = o_sx >= ACTIVE_H_PIXELS + H_FRONT_PORCH && 
                    o_sx <  ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNCH_WIDTH;
    assign o_vsync = o_sy >= ACTIVE_LINES + V_FRONT_PORCH &&
                   o_sy <  ACTIVE_LINES + V_FRONT_PORCH + V_SYNCH_WIDTH;
 
    assign o_de = o_sx < ACTIVE_H_PIXELS && o_sy < ACTIVE_LINES;
    assign o_nf = o_sx == 0 && o_sy == 0;
    
    always@(posedge i_clk_pxl)
    begin
        if (i_reset) begin
            o_sx <= 0;
            o_sy <= 0;
            o_fc <= 0;
        end
        else if (o_sx == TOTAL_PIXELS-1) begin
            o_sx <= 0;
            if (o_sy == TOTAL_LINES-1) begin
                o_sy <= 0;
                o_fc <= (o_fc == FPS-1) ? 0 : o_fc + 1;
            end
            else begin
                o_sy <= o_sy + 1;
            end
        end 
        else begin
            o_sx <= o_sx + 1;
        end
    end
endmodule
`default_nettype wire
