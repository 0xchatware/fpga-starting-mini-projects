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
                 parameter NUM_CHAR=256)(
    input wire i_clk,
    input wire [$clog2(NUM_CHAR)-1:0] i_character,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_sx,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_sy,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_x,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_y,
    input wire i_en,
    output logic o_data
    );
    
    localparam CHAR_Y_COLUMNS = 16;
    localparam CHAR_X_BITS = 8;
    localparam DEPTH = NUM_CHAR * CHAR_Y_COLUMNS;
    localparam FONT_FILE = "VGA8.F16.mem";
    
    logic [$clog2(DEPTH)-1:0] r_char_addr;
    logic [CHAR_X_BITS-1:0] r_data;
    
    logic [$clog2(CHAR_X_BITS)-1:0] r_char_x;
    logic [$clog2(CHAR_Y_COLUMNS)-1:0] r_char_y;
        
    ROM#(.WIDTH(CHAR_X_BITS), .DEPTH(DEPTH), .FILE(FONT_FILE)) Rom_Inst
    (
        .i_clk(i_clk),
        .i_wr_addr(8'b0),
        .i_rd_addr(r_char_addr),
        .i_wr_en(1'b0),
        .i_din(8'b0),
        .o_dout(r_data));
        
    assign r_char_addr = {i_character, r_char_y};
    assign r_char_x = i_sx[$clog2(CHAR_X_BITS)-1:0] - i_x[$clog2(CHAR_X_BITS)-1:0];
    assign r_char_y = i_sy[$clog2(CHAR_Y_COLUMNS)-1:0] - i_y[$clog2(CHAR_Y_COLUMNS)-1:0];
    
    assign o_data = (i_x <= i_sx) && (i_sx < i_x + CHAR_X_BITS) 
                    && (i_y <= i_sy) && (i_sy < i_y + CHAR_Y_COLUMNS)
                    && i_en ? r_data[r_char_x] : 0;
    
endmodule
`default_nettype wire