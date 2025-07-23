`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2025 03:38:43 PM
// Design Name: 
// Module Name: Font_ROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Inspired from https://github.com/adumont/fpga-font/blob/master/font.v
// 
//////////////////////////////////////////////////////////////////////////////////


module Font_ROM#(parameter HORIZONTAL_WIDTH=1650,
                 parameter VERTICAL_WIDTH=750,
                 parameter COLUMNS=12,
                 parameter ROWS=2,
                 parameter FONT_NUM_CHAR=256,
                 parameter FONT_FILE="VGA8.F16.mem",
                 parameter CHAR_PIXELS_X=8,
                 parameter CHAR_PIXELS_Y=16,
                 parameter SCALE_X=1,
                 parameter SCALE_Y=1)(
    input wire i_clk,
    input wire [$clog2(FONT_NUM_CHAR)-1:0] i_wr_character,
    input wire [$clog2(COLUMNS)-1:0] i_wr_x_pos,
    input wire [$clog2(ROWS)-1:0] i_wr_y_pos,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_sx,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_sy,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_x,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_y,
    input wire i_rd_en,
    input wire i_wr_en,
    output logic o_rd_dv, // character valid
    output logic o_rd_data
    );
    
    localparam DEPTH = FONT_NUM_CHAR * CHAR_PIXELS_Y;
    localparam CHAR_TABLE_SIZE = COLUMNS * ROWS;
    localparam PIXELS_X = CHAR_PIXELS_X * COLUMNS * SCALE_X;
    localparam PIXELS_Y = CHAR_PIXELS_Y * ROWS * SCALE_Y;
    
    logic [$clog2(CHAR_TABLE_SIZE)-1:0] r_wr_character_addr, r_rd_character_addr;
    logic [$clog2(FONT_NUM_CHAR)-1:0] r_rd_character;
    
    logic [$clog2(HORIZONTAL_WIDTH)-1:0] r_char_x_buff;
    logic [$clog2(VERTICAL_WIDTH)-1:0] r_char_y_buff;
    logic [$clog2(PIXELS_Y)-1:0] r_char_y;
    logic [$clog2(PIXELS_X)-1:0] r_char_x;
    logic [$clog2(CHAR_PIXELS_X)-1:0] r_char_x_d, r_char_x_dd;
    
    logic [$clog2(DEPTH)-1:0] r_char_addr;
    logic [CHAR_PIXELS_X-1:0] r_data;
    
    bit r_is_block, r_is_block_d;
    
    RAM_Single_Port#(.WIDTH($clog2(FONT_NUM_CHAR)), .DEPTH(CHAR_TABLE_SIZE), .INITIAL_ZERO(1)) Char_Table_Inst
    (
        .i_clk(i_clk),
        .i_wr_dv(i_wr_en),
        .i_wr_addr(r_wr_character_addr),
        .i_wr_data(i_wr_character),
        .i_rd_en(i_rd_en),
        .i_rd_addr(r_rd_character_addr),
        .o_rd_data(r_rd_character),
        .o_rd_dv(o_rd_dv));
        
    ROM#(.WIDTH(CHAR_PIXELS_X), .DEPTH(DEPTH), .FILE(FONT_FILE)) Font_Rom_Mem_Inst
    (
        .i_clk(i_clk),
        .i_rd_addr(r_char_addr),
        .o_dout(r_data));
        
    always_comb begin : determine_pixel_pos
        r_char_x_buff = i_sx - i_x;
        r_char_y_buff = i_sy - i_y;
        r_char_x = r_char_x_buff < $clog2(PIXELS_X) ? r_char_x_buff : $clog2(PIXELS_X)'(r_char_x_buff);
        r_char_y = r_char_y_buff < $clog2(PIXELS_Y) ? r_char_y_buff : $clog2(PIXELS_Y)'(r_char_y_buff);
        
        r_rd_character_addr = r_char_y/(CHAR_PIXELS_Y*SCALE_Y)*COLUMNS + r_char_x/(CHAR_PIXELS_X*SCALE_X);
    end
        
    always_ff@(posedge i_clk) begin : Synchronous_Delays
        if (i_rd_en) begin
            r_char_x_d <= $clog2(CHAR_PIXELS_X)'(r_char_x/SCALE_X);
            r_char_x_dd <= r_char_x_d;
            r_is_block <= is_block_zone();
            r_is_block_d <= r_is_block;
        end
    end
    
    assign r_wr_character_addr = i_wr_y_pos * COLUMNS + i_wr_x_pos;
    assign r_char_addr = r_is_block ? {r_rd_character, $clog2(CHAR_PIXELS_Y)'(r_char_y/SCALE_Y)} : 0;
    assign o_rd_data = r_is_block_d ? r_data[CHAR_PIXELS_X - 1 - r_char_x_dd] : 0;
                        
    function bit is_block_zone();
        return i_rd_en && (i_x <= i_sx) && (i_sx < (i_x + PIXELS_X)) 
                    && (i_y <= i_sy) && (i_sy < (i_y + PIXELS_Y));
    endfunction
    
endmodule
`default_nettype wire