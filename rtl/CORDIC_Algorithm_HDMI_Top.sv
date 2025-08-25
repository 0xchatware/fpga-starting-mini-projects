`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2025 11:29:55 AM
// Design Name: 
// Module Name: CORDIC_Algorithm_HDMI_Top
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


module CORDIC_Algorithm_HDMI_Top(
    input wire i_sys_clk,
    output logic [2:0] o_hdmi_tx_p,
    output logic [2:0] o_hdmi_tx_n,
    output logic o_hdmi_clk_p,
    output logic o_hdmi_clk_n
    );
    
    // Reset settings
    localparam byte RESET_TIMEOUT = 5; // for 200ns and a 25MHz clock
    localparam byte RESET_TIMEOUT_5x = 25; // for 200ns and a 125MHz clock
    
    // Video Signal Settigns
    localparam shortint TOTAL_VER_PIXEL = 750;
    localparam shortint TOTAL_HOR_PIXEL = 1650;
    localparam byte COLOUR_BITS = 8;
    
    // Text Overlay
    localparam shortint NUM_CHAR = 256;
    localparam string FONT_FILE = "KPRO2K_D.F16.mem";
    
    // Fixed numbers
    localparam byte INT_BITS = 3;
    localparam byte FRACTIONAL_BITS = 30;
    localparam shortint BITS = INT_BITS + FRACTIONAL_BITS;
    localparam byte N_ITERATION = FRACTIONAL_BITS/2;
    
    localparam logic [BITS-1:0] Z_VALUE = (BITS)'(int'(0.78 * 2**FRACTIONAL_BITS)); // takes 4 char
    localparam byte unsigned DISPLAY_FRAC_NUM = 4;
    localparam byte unsigned DISPLAY_INT_NUM = 2;
    // DISPLAY_INT_NUM + "." + DISPLAYED_FRAC_NUM
    // (DISPLAY_INT_NUM + 1 + DISPLAYED_FRAC_NUM) - 1
    localparam shortint unsigned DISPLAY_FIXED = DISPLAY_FRAC_NUM + DISPLAY_INT_NUM + 1;
    
    // "cos(%f) = %f"
    localparam shortint unsigned INITIAL_CHAR_NUM = 8 + DISPLAY_FIXED;
    localparam shortint unsigned CHAR_NUM = INITIAL_CHAR_NUM + DISPLAY_FIXED;
    localparam shortint unsigned TEXT_COLUMNS = CHAR_NUM;
    localparam logic [INITIAL_CHAR_NUM*8-1:0] DISPLAY_TEXT = {"cos(", fixed_to_char(Z_VALUE), ") = "};
    
    // Modes for CORDIC
    localparam logic signed [1:0] HYPERBOLIC = -1;
    localparam logic signed [1:0] LINEAR = 0;
    localparam logic signed [1:0] CIRCULAR = 1;
    
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
    
    // Creates a resets state machine
    logic [$clog2(RESET_TIMEOUT)-1:0] r_reset_count;
    logic [$clog2(RESET_TIMEOUT_5x)-1:0] r_reset_count_5x;
    logic r_clear_counter, r_clear_counter_5x;
    logic w_master_reset, w_master_reset_5x;  
    always_ff@(posedge w_clk_pxl) begin : master_reset
        r_clear_counter <= r_rst_src_pll;
        w_master_reset <= (r_reset_count != RESET_TIMEOUT);
        
        if (r_clear_counter)
          r_reset_count <= 0;
        else if (r_reset_count != RESET_TIMEOUT)
          r_reset_count <= r_reset_count + 1;
    end
    
    always_ff@(posedge w_clk_pxl_5x) begin : master_reset_5x
        r_clear_counter_5x <= r_rst_src_pll;
        w_master_reset_5x <= (r_reset_count_5x != RESET_TIMEOUT_5x);
        
        if (r_clear_counter_5x)
          r_reset_count_5x <= 0;
        else if (r_reset_count_5x != RESET_TIMEOUT_5x)
          r_reset_count_5x <= r_reset_count_5x + 1;
    end
    
    initial begin : reset_initial_values
        r_rst_src_pll = 1;
        r_rst_src_pll_pre = 1;
        r_reset_count = 0;
        r_clear_counter = 0;
        w_master_reset = 1;
        r_reset_count_5x = 0;
        r_clear_counter_5x = 0;
        w_master_reset_5x = 1;
    end
    
    logic w_cordic_ready, w_cordic_valid, w_cordic_rot_en_in, w_cordic_rot_en_out;
    logic [BITS-1:0] w_cordic_x_in, w_cordic_y_in, w_cordic_z_in, w_cordic_x_out, w_cordic_y_out, w_cordic_z_out;
    logic [1:0] w_cordic_mode_in, w_cordic_mode_out;
    logic [$clog2(RESET_TIMEOUT_5x)-1:0] w_cordic_ready_count;
    logic w_cordic_ready_clear;
    
    always_ff@(posedge w_clk_pxl_5x) begin : cordic_ready
        w_cordic_ready_clear <= w_master_reset_5x;
        w_cordic_ready <= w_cordic_ready_count != RESET_TIMEOUT_5x;
        
        if (w_cordic_ready_clear)
          w_cordic_ready_count <= 0;
        else if (w_cordic_ready_count != RESET_TIMEOUT_5x)
          w_cordic_ready_count <= w_cordic_ready_count + 1;
    end
    
    CORDIC_Algorithm #(.N_ITERATION(N_ITERATION),
                       .INTEGER_BITS(INT_BITS), // Q3.30 sign included
                       .FRACTIONAL_BITS(FRACTIONAL_BITS)) 
                       CORDIC_Algorithm_Inst (
        .i_clk(w_clk_pxl_5x),
        .i_rst(w_master_reset_5x),
        .i_ready(w_cordic_ready),
        .i_x(w_cordic_x_in),
        .i_y(w_cordic_y_in),
        .i_z(w_cordic_z_in), //theta
        .i_mode(w_cordic_mode_in),
        .i_rot_en(w_cordic_rot_en_in), // if not i_rot_en, vectoring mode
        .o_valid(w_cordic_valid),
        .o_x(w_cordic_x_out),
        .o_y(w_cordic_y_out),
        .o_z(w_cordic_z_out),
        .o_mode(w_cordic_mode_out),
        .o_rot_en(w_cordic_rot_en_out)
    );
    
    initial begin : set_intial_cordic_values
        w_cordic_ready = 1;
        w_cordic_mode_in = CIRCULAR;
        w_cordic_rot_en_in = 1;
        w_cordic_x_in = 0;
        w_cordic_y_in = 0;
        w_cordic_z_in = Z_VALUE;
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
    
    logic r_text_en, r_text_data, r_text_rd_dv, r_text_write_completed;
    logic [$clog2(TOTAL_HOR_PIXEL)-1:0] r_text_box_x;
    logic [$clog2(TOTAL_VER_PIXEL)-1:0] r_text_box_y;
    logic [CHAR_NUM-1:0][7:0] r_characters;
    logic r_text_wr_ready, r_text_wr_ready_clear;
    logic [$clog2(RESET_TIMEOUT)-1:0] r_text_ready_count;
    
    always_ff@(posedge w_clk_pxl) begin : text_ready_timer
        r_text_wr_ready_clear <= w_master_reset;
        r_text_wr_ready <= r_text_ready_count != RESET_TIMEOUT;
        
        if (r_text_wr_ready_clear) begin
            r_text_ready_count <= 0;
        end else if (r_text_ready_count != RESET_TIMEOUT)
          r_text_ready_count <= r_text_ready_count + 1;
    end
    
    always_ff@(posedge w_clk_pxl) begin : update_string
        if (w_cordic_valid) begin
            r_characters[CHAR_NUM-DISPLAY_FIXED:0] <= {DISPLAY_TEXT, fixed_to_char(w_cordic_x_out)};
        end
    end
    
    Text_Overlay#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
                  .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
                  .COLUMNS(TEXT_COLUMNS),
                  .NUM_CHAR(CHAR_NUM),
                  .FONT_FILE(FONT_FILE),
                  .CHAR_PIXELS_X(8),
                  .CHAR_PIXELS_Y(16),
                  .SCALE_X(2),
                  .SCALE_Y(2)
    ) Cordic_result_display (
        .i_clk(w_clk_pxl),
        .i_characters(r_characters),
        .i_sx(w_sx),
        .i_sy(w_sy),
        .i_x(r_text_box_x),
        .i_y(r_text_box_y),
        .i_rd_en(r_text_en),
        .i_wr_ready(r_text_wr_ready),
        .o_wr_completed(r_text_write_completed),
        .o_rd_dv(r_text_rd_dv),
        .o_data(r_text_data)
    );
    
    initial begin : text_overlay_initial_values
        r_text_box_x = 0;
        r_text_box_y = 0;
        r_text_en = 1;
        r_text_ready_count = 0;
        r_characters = {>>{DISPLAY_TEXT}}; // unpacked to packed
    end
        
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    always_ff@(posedge w_clk_pxl) begin : set_display_values
        if (r_text_rd_dv && r_text_write_completed) begin
            v_paint_r <= r_text_data ? 8'hFF : 8'h00;
            v_paint_g <= r_text_data ? 8'hFF : 8'h00;
            v_paint_b <= r_text_data ? 8'hFF : 8'h00;
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
    
    
    function logic unsigned [DISPLAY_FIXED*8-1:0] fixed_to_char(input logic signed [BITS-1:0] value);
        static logic signed [BITS-1:0] abs_value = (value < 0) ? -value : value;
        static logic unsigned [INT_BITS-1:0] int_part = (INT_BITS-1)'(abs_value >>> FRACTIONAL_BITS);
        static logic unsigned [FRACTIONAL_BITS-1:0] frac_part = (FRACTIONAL_BITS)'(abs_value);
        static logic unsigned [63:0] frac_raw;
        
        // Sign
        fixed_to_char[DISPLAY_FIXED*8-1 -: 8] = value[BITS-1] == 1 ? "-" : "+";
        
        // Integer Part (without sign)
        for (byte i = 0; i < DISPLAY_INT_NUM; i++) begin
            fixed_to_char[(DISPLAY_FRAC_NUM+i)*8 +: 8] = "0" + int_part/($unsigned(10**i))%10;
        end
        
        // Dot
        fixed_to_char[(DISPLAY_FIXED-DISPLAY_INT_NUM)*8-1 -: 8] = ".";
        
        // Fractional part
        for (byte i = 0; i < DISPLAY_FRAC_NUM; i++) begin
            frac_raw = (((frac_part * $unsigned(10**(i+1))) >> FRACTIONAL_BITS) % 10);
            fixed_to_char[(DISPLAY_FIXED-DISPLAY_INT_NUM-1-i)*8-1 -: 8] =  "0" + frac_raw;
        end
        return fixed_to_char;
    endfunction
    
endmodule
`default_nettype wire
