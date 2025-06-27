`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 09:53:21 PM
// Design Name: 
// Module Name: Pong_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pong_720p_Top(
    input wire i_sys_clk,
    input wire [1:0] i_sw,
    input wire [1:0] i_control,
    output logic [2:0] o_hdmi_tx_p,
    output logic [2:0] o_hdmi_tx_n,
    output logic o_hdmi_clk_p,
    output logic o_hdmi_clk_n
    );
    
    localparam COLOUR_BITS = 8;
    localparam RESET_TIMEOUT = 93750000; // for 50ns and a 25MHz clock
    localparam ACTIVE_H_PIXELS = 1280;
    localparam H_FRONT_PORCH = 110;
    localparam H_SYNCH_WIDTH = 40;
    localparam H_BACK_PORCH = 220;
    localparam TOTAL_HOR_PIXEL = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNCH_WIDTH + H_BACK_PORCH;
    localparam ACTIVE_LINES = 720;
    localparam V_FRONT_PORCH = 5;
    localparam V_SYNCH_WIDTH = 5;
    localparam V_BACK_PORCH = 20;
    localparam TOTAL_VER_PIXEL = ACTIVE_LINES + V_FRONT_PORCH + V_SYNCH_WIDTH + V_BACK_PORCH;
    localparam FPS = 60;
    
    logic w_clk_pxl, w_clk_pxl_5x;
    logic w_clk_locked;
    clk_wiz_720p_0 Clk_Generator_Inst(
       .o_clk_pxl(w_clk_pxl),
       .o_clk_pxl_5x(w_clk_pxl_5x),
       .i_locked(w_clk_locked),
       .i_clk(i_sys_clk));
       
    logic rst_src_pll = 1;
    logic rst_src_pll_pre = 1;
    always@(posedge w_clk_pxl) begin
        rst_src_pll = rst_src_pll_pre;
        rst_src_pll_pre = !w_clk_locked;
    end
    
    // Creates a reset state machine
    logic [$clog2(RESET_TIMEOUT)-1:0] reset_count = 0;
    logic clear_counter = 1;
    logic master_reset = 1;
    always @(posedge w_clk_pxl)
    begin
        clear_counter <= rst_src_pll;
        master_reset <= (reset_count != RESET_TIMEOUT);
        
        if (clear_counter)
          reset_count <= 0;
        else if (reset_count != RESET_TIMEOUT)
          reset_count <= reset_count + 1;
    end 
    
    logic [$clog2(TOTAL_HOR_PIXEL)-1:0] w_sx;
    logic [$clog2(TOTAL_VER_PIXEL)-1:0] w_sy;
    logic [$clog2(FPS)-1:0] w_fc;
    logic w_hsync, w_vsync;
    logic w_de, w_nf;
    Video_Signal_Generator #( 
        .ACTIVE_H_PIXELS(ACTIVE_H_PIXELS),
        .H_FRONT_PORCH(H_FRONT_PORCH),
        .H_SYNCH_WIDTH(H_SYNCH_WIDTH),
        .H_BACK_PORCH(H_BACK_PORCH),
        .ACTIVE_LINES(ACTIVE_LINES),
        .V_FRONT_PORCH(V_FRONT_PORCH),
        .V_SYNCH_WIDTH(V_SYNCH_WIDTH),
        .V_BACK_PORCH(V_BACK_PORCH),
        .FPS(FPS)
    )Video_Signal_Inst(
        .i_clk_pxl(w_clk_pxl),
        .i_reset(master_reset),
        .o_sx(w_sx),
        .o_sy(w_sy),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_de(w_de),
        .o_nf(w_nf),
        .o_fc(w_fc));
    
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    
    Pong Pong_Inst(
          .i_pixel_clk(w_clk_pxl),
          .i_rst(master_reset),
          .i_control(i_control),
          .i_puck_speed(i_sw[0]),
          .i_paddle_speed(i_sw[1]),
          .i_nf(w_nf),
          .i_hcount(w_sx),
          .i_vcount(w_sy),
          .o_red(v_paint_r),
          .o_green(v_paint_g),
          .o_blue(v_paint_b)
          );
    
    logic [9:0] w_tmds_red_buffer, w_tmds_blue_buffer, w_tmds_green_buffer;
    logic w_tmds_signal_red, w_tmds_signal_blue, w_tmds_signal_green;
    logic w_tmds_signal_red_buffer, w_tmds_signal_blue_buffer, w_tmds_signal_green_buffer;
    
    TMDS_Encoder TMDS_Red (
        .i_clk(w_clk_pxl),
        .i_rst(master_reset),
        .i_data(v_paint_r),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_red_buffer));
    
    TMDS_Encoder TMDS_Green (
        .i_clk(w_clk_pxl),
        .i_rst(master_reset),
        .i_data(v_paint_g),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_green_buffer));
    
    TMDS_Encoder TMDS_Blue (
        .i_clk(w_clk_pxl),
        .i_rst(master_reset),
        .i_data(v_paint_b),
        .i_control({w_vsync, w_hsync}),
        .i_ve(w_de),
        .o_tmds(w_tmds_blue_buffer));
    
    TMDS_Serializer TMDS_Red_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(master_reset),
        .i_tmds(w_tmds_red_buffer),
        .o_tmds(w_tmds_signal_red));
        
    TMDS_Serializer TMDS_Green_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(master_reset),
        .i_tmds(w_tmds_green_buffer),
        .o_tmds(w_tmds_signal_green));
    
    TMDS_Serializer TMDS_Blue_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(master_reset),
        .i_tmds(w_tmds_blue_buffer),
        .o_tmds(w_tmds_signal_blue));
    
    OBUFDS OBUFDS_blue (.I(w_tmds_signal_blue), .O(o_hdmi_tx_p[0]), .OB(o_hdmi_tx_n[0]));
    OBUFDS OBUFDS_green(.I(w_tmds_signal_green), .O(o_hdmi_tx_p[1]), .OB(o_hdmi_tx_n[1]));
    OBUFDS OBUFDS_red  (.I(w_tmds_signal_red), .O(o_hdmi_tx_p[2]), .OB(o_hdmi_tx_n[2]));
    OBUFDS OBUFDS_clock(.I(w_clk_pxl), .O(o_hdmi_clk_p), .OB(o_hdmi_clk_n));
endmodule
