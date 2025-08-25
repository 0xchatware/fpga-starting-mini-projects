`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2025 03:13:13 PM
// Design Name: 
// Module Name: Text_Overlay_720p_Top
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


module Text_Overlay_720p_Top(
    input wire i_sys_clk,
    output logic [2:0] o_hdmi_tx_p,
    output logic [2:0] o_hdmi_tx_n,
    output logic o_hdmi_clk_p,
    output logic o_hdmi_clk_n
    );
    
    localparam TOTAL_VER_PIXEL = 750;
    localparam TOTAL_HOR_PIXEL = 1650;
    localparam COLOUR_BITS = 8;
    localparam RESET_TIMEOUT = 5; // for 200ns and a 25MHz clock
    localparam HELLO_WORLD_CHAR_NUM = 13;
    localparam TEXT_COLUMNS = HELLO_WORLD_CHAR_NUM;
    localparam NUM_CHAR = 256;
    
    logic w_clk_pxl, w_clk_pxl_5x;
    logic w_clk_locked;
    clk_wiz_720p_0 Clk_Generator_Inst(
       .o_clk_pxl(w_clk_pxl),
       .o_clk_pxl_5x(w_clk_pxl_5x),
       .i_locked(w_clk_locked),
       .i_clk(i_sys_clk));
       
    logic r_rst_src_pll;
    logic r_rst_src_pll_pre;
    
    always_ff@(posedge w_clk_pxl) begin
        r_rst_src_pll <= r_rst_src_pll_pre;
        r_rst_src_pll_pre <= !w_clk_locked;
    end
    
    // Creates a reset state machine
    logic [$clog2(RESET_TIMEOUT)-1:0] r_reset_count;
    logic r_clear_counter;
    logic w_master_reset;
    logic r_text_write_completed1, r_text_write_completed2, r_text_write_completed3;
    
    initial begin : reset_initial_values
        r_rst_src_pll = 1;
        r_rst_src_pll_pre = 1;
        r_reset_count = 0;
        r_clear_counter = 0;
        w_master_reset = 1;
    end
    
    always_ff@(posedge w_clk_pxl)
    begin
        r_clear_counter <= r_rst_src_pll || !r_text_write_completed1 || !r_text_write_completed2 || !r_text_write_completed3;
        w_master_reset <= (r_reset_count != RESET_TIMEOUT);
        
        if (r_clear_counter)
          r_reset_count <= 0;
        else if (r_reset_count != RESET_TIMEOUT)
          r_reset_count <= r_reset_count + 1;
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
        .i_reset(w_master_reset),
        .o_sx(w_sx),
        .o_sy(w_sy),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_de(w_de),
        .o_nf(),
        .o_fc());
    
    logic r_text_en, r_text_data1, r_text_data2, r_text_data3, r_text_rd_dv1, r_text_rd_dv2, r_text_rd_dv3;
    logic [$clog2(TOTAL_HOR_PIXEL)-1:0] r_text_box_x1, r_text_box_x2, r_text_box_x3;
    logic [$clog2(TOTAL_VER_PIXEL)-1:0] r_text_box_y1, r_text_box_y2, r_text_box_y3;
    logic [HELLO_WORLD_CHAR_NUM-1:0][7:0] r_characters;
    logic r_text_wr_ready;
    logic [$clog2(RESET_TIMEOUT)-1:0] r_text_ready_count;
    
    initial begin : text_overlay_initial_values
        r_text_box_x1 = 0;
        r_text_box_y1 = 0;
        r_text_box_x2 = 100;
        r_text_box_y2 = 100;
        r_text_box_x3 = 200;
        r_text_box_y3 = 200;
        r_text_en = 1;
        r_text_ready_count = 0;
        r_characters = "Hello, world!";
    end
    
    always_ff@(posedge w_clk_pxl) begin : text_ready_timer
        r_text_wr_ready <= r_text_ready_count != RESET_TIMEOUT;
          
        if (r_text_ready_count != RESET_TIMEOUT)
          r_text_ready_count <= r_text_ready_count + 1;
    end
    
    
    Text_Overlay#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
                  .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
                  .COLUMNS(TEXT_COLUMNS),
                  .NUM_CHAR(HELLO_WORLD_CHAR_NUM),
                  .FONT_FILE("VGA8.F16.mem"),
                  .CHAR_PIXELS_X(8),
                  .CHAR_PIXELS_Y(16),
                  .SCALE_X(1),
                  .SCALE_Y(1)
    ) Hello_Text_Box_Inst (
        .i_clk(w_clk_pxl),
        .i_characters(r_characters),
        .i_sx(w_sx),
        .i_sy(w_sy),
        .i_x(r_text_box_x1),
        .i_y(r_text_box_y1),
        .i_rd_en(r_text_en),
        .i_wr_ready(r_text_wr_ready),
        .o_wr_completed(r_text_write_completed1),
        .o_rd_dv(r_text_rd_dv1),
        .o_data(r_text_data1)
    );
    
    Text_Overlay#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
                  .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
                  .COLUMNS(TEXT_COLUMNS),
                  .NUM_CHAR(HELLO_WORLD_CHAR_NUM),
                  .FONT_FILE("VGA8.F16.mem"),
                  .CHAR_PIXELS_X(8),
                  .CHAR_PIXELS_Y(16),
                  .SCALE_X(2),
                  .SCALE_Y(2)
    ) Hello_Text_Box_2x_Inst (
        .i_clk(w_clk_pxl),
        .i_characters(r_characters),
        .i_sx(w_sx),
        .i_sy(w_sy),
        .i_x(r_text_box_x2),
        .i_y(r_text_box_y2),
        .i_rd_en(r_text_en),
        .i_wr_ready(r_text_wr_ready),
        .o_wr_completed(r_text_write_completed2),
        .o_rd_dv(r_text_rd_dv2),
        .o_data(r_text_data2)
    );
    
    Text_Overlay#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
                  .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
                  .COLUMNS(TEXT_COLUMNS),
                  .NUM_CHAR(HELLO_WORLD_CHAR_NUM),
                  .FONT_FILE("KPRO2K_D.F16.mem"),
                  .CHAR_PIXELS_X(8),
                  .CHAR_PIXELS_Y(16),
                  .SCALE_X(9),
                  .SCALE_Y(9)
    ) Hello_Text_Box_9x_Inst (
        .i_clk(w_clk_pxl),
        .i_characters(r_characters),
        .i_sx(w_sx),
        .i_sy(w_sy),
        .i_x(r_text_box_x3),
        .i_y(r_text_box_y3),
        .i_rd_en(r_text_en),
        .i_wr_ready(r_text_wr_ready),
        .o_wr_completed(r_text_write_completed3),
        .o_rd_dv(r_text_rd_dv3),
        .o_data(r_text_data3)
    );
        
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    always_ff@(posedge w_clk_pxl) begin
        if (r_text_rd_dv1 && r_text_rd_dv2 && r_text_rd_dv3) begin
            v_paint_r <= r_text_data1 || r_text_data2 || r_text_data3 ? 8'hFF : 8'h00;
            v_paint_g <= r_text_data1 || r_text_data2 || r_text_data3 ? 8'hFF : 8'h00;
            v_paint_b <= r_text_data1 || r_text_data2 || r_text_data3 ? 8'hFF : 8'h00;
        end
    end
    
    logic [9:0] w_tmds_red_buffer, w_tmds_blue_buffer, w_tmds_green_buffer;
    logic w_tmds_signal_red, w_tmds_signal_blue, w_tmds_signal_green;
    
    TMDS_Encoder TMDS_Red (
        .i_clk(w_clk_pxl),
        .i_rst(w_master_reset),
        .i_data(v_paint_r),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_red_buffer));
    
    TMDS_Encoder TMDS_Green (
        .i_clk(w_clk_pxl),
        .i_rst(w_master_reset),
        .i_data(v_paint_g),
        .i_control(2'b00),
        .i_ve(w_de),
        .o_tmds(w_tmds_green_buffer));
    
    TMDS_Encoder TMDS_Blue (
        .i_clk(w_clk_pxl),
        .i_rst(w_master_reset),
        .i_data(v_paint_b),
        .i_control({w_vsync, w_hsync}),
        .i_ve(w_de),
        .o_tmds(w_tmds_blue_buffer));
    
    TMDS_Serializer TMDS_Red_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(w_master_reset),
        .i_tmds(w_tmds_red_buffer),
        .o_tmds(w_tmds_signal_red));
        
    TMDS_Serializer TMDS_Green_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(w_master_reset),
        .i_tmds(w_tmds_green_buffer),
        .o_tmds(w_tmds_signal_green));
    
    TMDS_Serializer TMDS_Blue_Serializer (
        .i_clk_pixel(w_clk_pxl),
        .i_clk_5x(w_clk_pxl_5x),
        .i_rst(w_master_reset),
        .i_tmds(w_tmds_blue_buffer),
        .o_tmds(w_tmds_signal_blue));
    
    OBUFDS OBUFDS_blue (.I(w_tmds_signal_blue), .O(o_hdmi_tx_p[0]), .OB(o_hdmi_tx_n[0]));
    OBUFDS OBUFDS_green(.I(w_tmds_signal_green), .O(o_hdmi_tx_p[1]), .OB(o_hdmi_tx_n[1]));
    OBUFDS OBUFDS_red  (.I(w_tmds_signal_red), .O(o_hdmi_tx_p[2]), .OB(o_hdmi_tx_n[2]));
    OBUFDS OBUFDS_clock(.I(w_clk_pxl), .O(o_hdmi_clk_p), .OB(o_hdmi_clk_n));
endmodule
`default_nettype wire
