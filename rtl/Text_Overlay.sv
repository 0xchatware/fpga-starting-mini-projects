`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2025 09:01:59 AM
// Design Name: 
// Module Name: Text_Overlay
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


module Text_Overlay#(parameter HORIZONTAL_WIDTH=1650,
                     parameter VERTICAL_WIDTH=750,
                     parameter COLUMNS=16,
                     parameter NUM_CHAR=300)(
    input wire i_clk,
    input wire [NUM_CHAR*8-1:0] i_characters,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_sx,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_sy,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_x,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_y,
    input wire i_rd_en,
    output logic o_rd_dv,
    output wire o_data
    );
    
    localparam NUM_OF_POSSIBLE_CHAR = 256;
    localparam ROWS = (NUM_CHAR+COLUMNS-1)/(COLUMNS);
    
    logic [NUM_CHAR*$clog2(NUM_CHAR)-1:0] r_prev_characters, r_cur_characters;
    logic [$clog2(NUM_CHAR)-1:0] r_i;
    
    logic [$clog2(NUM_OF_POSSIBLE_CHAR)-1:0] r_character;
    logic [$clog2(COLUMNS)-1:0] r_wr_x_pos;
    logic [$clog2(ROWS)-1:0] r_wr_y_pos;
    logic r_wr_en;
    
    Font_ROM#(.HORIZONTAL_WIDTH(HORIZONTAL_WIDTH),
              .VERTICAL_WIDTH(VERTICAL_WIDTH),
              .CHAR_BUFF_COLUMNS(COLUMNS),
              .CHAR_BUFF_ROWS(ROWS)
    ) Char_Data_Inst (
        .i_clk(i_clk),
        .i_wr_character(r_character),
        .i_wr_x_pos(r_wr_x_pos),
        .i_wr_y_pos(r_wr_y_pos),
        .i_sx(i_sx),
        .i_sy(i_sy),
        .i_x(i_x),
        .i_y(i_y),
        .i_rd_en(i_rd_en),
        .i_wr_en(r_wr_en),
        .o_rd_data(o_data));
        
    always_ff@(posedge i_clk) begin
        r_cur_characters <= i_characters;
        
        if (r_prev_characters != r_cur_characters) begin
            r_i <= 0;
            r_wr_en <= 1;
            o_rd_dv <= 0;
            r_prev_characters <= i_characters;
        end else if (r_wr_en) begin
            r_character <= i_characters[8 * (NUM_CHAR-r_i-1) +: 8];
            r_wr_x_pos <= r_i % COLUMNS;
            r_wr_y_pos <= r_i / COLUMNS;
            r_wr_en <= r_i == NUM_CHAR ? 0 : 1;
            o_rd_dv <= r_i == NUM_CHAR ? 1 : 0;
            r_i <= r_i + 1;
        end
    end
        
endmodule
`default_nettype wire
