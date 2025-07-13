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
                 parameter CHAR_BUFF_COLUMNS=12,
                 parameter CHAR_BUFF_ROWS=2,
                 parameter FONT_NUM_CHAR=256)(
    input wire i_clk,
    input wire [$clog2(FONT_NUM_CHAR)-1:0] i_wr_character,
    input wire [$clog2(CHAR_BUFF_COLUMNS)-1:0] i_wr_x_pos,
    input wire [$clog2(CHAR_BUFF_ROWS)-1:0] i_wr_y_pos,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_sx,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_sy,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_x,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_y,
    input wire i_rd_en,
    input wire i_wr_en,
    output logic o_rd_data
    );
    
    localparam CHAR_Y_COLUMNS = 16;
    localparam CHAR_X_BITS = 8;
    localparam DEPTH = FONT_NUM_CHAR * CHAR_Y_COLUMNS;
    localparam FONT_FILE = "VGA8.F16.mem";
    localparam CHAR_TABLE_SIZE = CHAR_BUFF_COLUMNS * CHAR_BUFF_ROWS;
    localparam BLOCK_X = CHAR_X_BITS * CHAR_BUFF_COLUMNS;
    localparam BLOCK_Y = CHAR_Y_COLUMNS * CHAR_BUFF_ROWS;
    
    logic [$clog2(CHAR_TABLE_SIZE)-1:0] r_wr_character_addr, r_rd_character_addr;
    logic [$clog2(FONT_NUM_CHAR)-1:0] r_rd_character;
    logic r_rd_character_dv;
    
    logic [$clog2(BLOCK_X)-1:0] r_char_x;
    logic [$clog2(CHAR_X_BITS)-1:0] r_char_x_d, r_char_x_dd;
    logic [$clog2(BLOCK_Y)-1:0] r_char_y;
    logic [$clog2(CHAR_BUFF_COLUMNS)-1:0] r_table_x;
    logic [$clog2(CHAR_BUFF_ROWS)-1:0] r_table_y;
    
    logic [$clog2(DEPTH)-1:0] r_char_addr;
    logic [CHAR_X_BITS-1:0] r_data;
    
    bit r_is_block, r_is_block_d;
    
    RAM#(.WIDTH($clog2(FONT_NUM_CHAR)), .DEPTH(CHAR_TABLE_SIZE), .INITIAL_ZERO(1)) Char_Table_Inst
    (
        .i_wr_clk(i_clk),
        .i_wr_dv(i_wr_en),
        .i_wr_addr(r_wr_character_addr),
        .i_wr_data(i_wr_character),
        .i_rd_clk(i_clk),
        .i_rd_en(i_rd_en),
        .i_rd_addr(r_rd_character_addr),
        .o_rd_data(r_rd_character),
        .o_rd_dv(r_rd_character_dv));
        
    ROM#(.WIDTH(CHAR_X_BITS), .DEPTH(DEPTH), .FILE(FONT_FILE)) Font_Rom_Mem_Inst
    (
        .i_clk(i_clk),
        .i_rd_addr(r_char_addr),
        .o_dout(r_data));
        
    assign r_char_x = i_sx[$clog2(BLOCK_X)-1:0] - i_x[$clog2(BLOCK_X)-1:0];
    assign r_char_y = i_sy[$clog2(BLOCK_Y)-1:0] - i_y[$clog2(BLOCK_Y)-1:0];
    assign r_wr_character_addr = i_wr_y_pos * CHAR_BUFF_COLUMNS + i_wr_x_pos;
    
    assign r_table_x = r_char_x / CHAR_X_BITS;
    assign r_table_y = r_char_y / CHAR_Y_COLUMNS;
    assign r_rd_character_addr = r_table_y * CHAR_BUFF_COLUMNS + r_table_x;
    
    always_ff@(posedge i_clk) begin : Synchronous_Delays
        if (i_rd_en) begin
            r_char_x_d <= r_char_x[$clog2(CHAR_X_BITS)-1:0];
            r_char_x_dd <= r_char_x_d[$clog2(CHAR_X_BITS)-1:0];
            r_is_block <= is_block_zone();
            r_is_block_d <= r_is_block;
        end
    end
    
    assign r_char_addr = r_is_block ? {r_rd_character, r_char_y[$clog2(CHAR_Y_COLUMNS)-1:0]} : 0; // if not valid use " "
    assign o_rd_data = r_is_block_d ? r_data[CHAR_X_BITS - 1 - r_char_x_dd[$clog2(CHAR_X_BITS)-1:0]] : 0;
                        
    function bit is_block_zone();
        return i_rd_en && (i_x <= i_sx) && (i_sx < (i_x + BLOCK_X)) 
                    && (i_y <= i_sy) && (i_sy < (i_y + BLOCK_Y));
    endfunction
    
endmodule
`default_nettype wire