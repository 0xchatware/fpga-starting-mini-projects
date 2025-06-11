`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 09:26:31 AM
// Design Name: 
// Module Name: Hdmi_Pattern_Top
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


module Square_Pattern_Hdmi_480p_Top(
    input i_sys_clk,
    output [2:0] o_hdmi_tx_p,
    output [2:0] o_hdmi_tx_n,
    output o_hdmi_clk_p,
    output o_hdmi_clk_n
    );
    
    parameter COORD_BITS = 10;
    parameter COLOUR_BITS = 8;
    parameter RESET_TIMEOUT = 6250000; // for 50ns and a 125MHz clock
    
    logic w_clk_25Mhz, w_clk_125MHz;
    logic w_clk_locked;
    clk_wiz_0 Clk_Generator_Inst(
       .o_clk_25MHz(w_clk_25MHz),
       .o_clk_125MHz(w_clk_125MHz),
       .i_locked(w_clk_locked),
       .i_clk(i_sys_clk));
       
    logic rst_src_pll = 1;
    logic rst_src_pll_pre = 1;
    always@(posedge w_clk_25MHz) begin
        rst_src_pll = rst_src_pll_pre;
        rst_src_pll_pre = !w_clk_locked;
    end
    
    // Creates a reset state machine
    logic [$clog2(RESET_TIMEOUT)-1:0] reset_count = 0;
    logic clear_counter = 1;
    logic master_reset = 1;
    always @(posedge w_clk_25MHz)
      begin
        clear_counter <= rst_src_pll;
        master_reset <= (reset_count != RESET_TIMEOUT);
    
        if (clear_counter)
          reset_count <= 0;
        else if (reset_count != RESET_TIMEOUT)
          reset_count <= reset_count + 1;
      end
    
    logic [COORD_BITS-1:0] w_sx, w_sy;
    logic w_hsync, w_vsync;
    logic w_de;
    Video_Signal_Generator Video_Signal_Inst(
        .i_clk_pxl(w_clk_25MHz),
        .i_reset(master_reset),
        .o_sx(w_sx),
        .o_sy(w_sy),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_de(w_de),
        .o_nf(),
        .o_fc());
    
    logic v_square;
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    always_comb begin
        v_square = (w_sx > 220 && w_sx < 420) && (w_sy > 140 && w_sy < 340);
        
        // White outside the square, blue inside the square.
        v_paint_r = (v_square) ? 8'hFF : 8'h00;
        v_paint_g = (v_square) ? 8'hFF : 8'h00;
        v_paint_b = (v_square) ? 8'hFF : 8'h8B;
    end
    
    logic [9:0] w_tmds_red_buffer, w_tmds_blue_buffer, w_tmds_green_buffer;
    logic w_tmds_signal_red, w_tmds_signal_blue, w_tmds_signal_green;
    
    TMDS_Encoder TMDS_Red (
        .i_clk(w_clk_25MHz),
        .i_rst(master_reset),
        .i_data(v_paint_r),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_red_buffer));
    
    TMDS_Encoder TMDS_Green (
        .i_clk(w_clk_25MHz),
        .i_rst(master_reset),
        .i_data(v_paint_g),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_green_buffer));
    
    TMDS_Encoder TMDS_Blue (
        .i_clk(w_clk_25MHz),
        .i_rst(master_reset),
        .i_data(v_paint_b),
        .i_control({w_vsync, w_hsync}),
        .i_ve(w_de),
        .o_tmds(w_tmds_blue_buffer));
    
    TMDS_Serializer TMDS_Red_Serializer (
        .i_clk_pixel(w_clk_25MHz),
        .i_clk_5x(w_clk_125MHz),
        .i_rst(master_reset),
        .i_tmds(w_tmds_red_buffer),
        .o_tmds(w_tmds_signal_red));
        
    TMDS_Serializer TMDS_Green_Serializer (
        .i_clk_pixel(w_clk_25MHz),
        .i_clk_5x(w_clk_125MHz),
        .i_rst(master_reset),
        .i_tmds(w_tmds_green_buffer),
        .o_tmds(w_tmds_signal_green));
    
    TMDS_Serializer TMDS_Blue_Serializer (
        .i_clk_pixel(w_clk_25MHz),
        .i_clk_5x(w_clk_125MHz),
        .i_rst(master_reset),
        .i_tmds(w_tmds_blue_buffer),
        .o_tmds(w_tmds_signal_blue));
    
    OBUFDS OBUFDS_blue (.I(w_tmds_signal_blue), .O(o_hdmi_tx_p[0]), .OB(o_hdmi_tx_n[0]));
    OBUFDS OBUFDS_green(.I(w_tmds_signal_green), .O(o_hdmi_tx_p[1]), .OB(o_hdmi_tx_n[1]));
    OBUFDS OBUFDS_red  (.I(w_tmds_signal_red), .O(o_hdmi_tx_p[2]), .OB(o_hdmi_tx_n[2]));
    OBUFDS OBUFDS_clock(.I(w_clk_25MHz), .O(o_hdmi_clk_p), .OB(o_hdmi_clk_n));
    
endmodule
