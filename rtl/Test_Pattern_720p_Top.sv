`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2025 04:00:09 PM
// Design Name: 
// Module Name: Test_Pattern_720p_Top
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

module Test_Pattern_720p_Top(
    input wire i_sys_clk,
    input wire [1:0] i_sw,
    output logic [2:0] o_hdmi_tx_p,
    output logic [2:0] o_hdmi_tx_n,
    output logic o_hdmi_clk_p,
    output logic o_hdmi_clk_n
    );
    
    localparam TOTAL_VER_PIXEL = 750;
    localparam TOTAL_HOR_PIXEL = 1650;
    localparam COLOUR_BITS = 8;
    localparam RESET_TIMEOUT = 93750000; // for 50ns and a 25MHz clock
    
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
    logic w_hsync, w_vsync;
    logic w_de;
    Video_Signal_Generator #( 
        .ACTIVE_H_PIXELS(1280),
        .H_FRONT_PORCH(110),
        .H_SYNCH_WIDTH(40),
        .H_BACK_PORCH(220),
        .ACTIVE_LINES(720),
        .V_FRONT_PORCH(5),
        .V_SYNCH_WIDTH(5),
        .V_BACK_PORCH(20),
        .FPS(60)
    )Video_Signal_Inst(
        .i_clk_pxl(w_clk_pxl),
        .i_reset(master_reset),
        .o_sx(w_sx),
        .o_sy(w_sy),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_de(w_de),
        .o_nf(),
        .o_fc());
    
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    
    Test_Pattern_Generator Test_Pattern_Inst(
          .i_sel(i_sw),
          .i_hcount(w_sx),
          .i_vcount(w_sy),
          .o_red(v_paint_r),
          .o_green(v_paint_g),
          .o_blue(v_paint_b));
    
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
`default_nettype wire