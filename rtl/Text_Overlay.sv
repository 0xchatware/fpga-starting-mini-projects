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
                     parameter NUM_CHAR=300,
                     parameter FONT_FILE="VGA8.F16.mem",
                     parameter CHAR_PIXELS_X=8,
                     parameter CHAR_PIXELS_Y=16,
                     parameter SCALE_X=1,
                     parameter SCALE_Y=1)(
    input wire i_clk,
    input wire [NUM_CHAR-1:0][7:0] i_characters,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_sx,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_sy,
    input wire [$clog2(HORIZONTAL_WIDTH)-1:0] i_x,
    input wire [$clog2(VERTICAL_WIDTH)-1:0] i_y,
    input wire i_rd_en,
    input wire i_wr_ready,
    output logic o_wr_completed,
    output logic o_rd_dv,
    output logic o_data
    );
    
    localparam shortint NUM_OF_POSSIBLE_CHAR = 256;
    localparam shortint ROWS = (NUM_CHAR+COLUMNS-1)/(COLUMNS);
    
    localparam logic INITIAL_STATE = 1'b0;
    localparam logic CALCULATION_STATE = 1'b1;
    
    logic [$clog2(NUM_CHAR)-1:0] r_i, r_i_synchronizer;
    
    logic [$clog2(NUM_OF_POSSIBLE_CHAR)-1:0] r_character;
    logic [$clog2(COLUMNS)-1:0] r_wr_x_pos;
    logic [$clog2(ROWS)-1:0] r_wr_y_pos;
    logic r_wr_en;
    
    logic r_cur_state;
    initial r_cur_state = INITIAL_STATE;
    
    Font_ROM#(.HORIZONTAL_WIDTH(HORIZONTAL_WIDTH),
              .VERTICAL_WIDTH(VERTICAL_WIDTH),
              .COLUMNS(COLUMNS),
              .ROWS(ROWS),
              .FONT_FILE(FONT_FILE),
              .CHAR_PIXELS_X(CHAR_PIXELS_X),
              .CHAR_PIXELS_Y(CHAR_PIXELS_Y),
              .SCALE_X(SCALE_X),
              .SCALE_Y(SCALE_Y)
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
        .o_rd_dv(o_rd_dv),
        .o_rd_data(o_data));
        
    always_ff@(posedge i_clk) begin
        case (r_cur_state)
            INITIAL_STATE: begin
                if (i_wr_ready) begin
                    r_cur_state <= CALCULATION_STATE;
                    r_i <= 0;
                    r_i_synchronizer <= 0;
                end
            end
            CALCULATION_STATE: begin
                r_character <= i_characters[NUM_CHAR-r_i-1];
                r_wr_x_pos <= r_i % COLUMNS;
                r_wr_y_pos <= r_i / COLUMNS;
                r_i <= r_i + 1;
                
                // r_i_synchronizer helps to add one cycle to r_i,
                // if r_i == 13, the value will skip the calculations
                // for the last character.
                r_i_synchronizer <= r_i;
                r_wr_en <= r_i_synchronizer == NUM_CHAR-1 ? 0 : 1;
                r_cur_state <= r_i_synchronizer == NUM_CHAR-1 
                                ? INITIAL_STATE : CALCULATION_STATE;
            end
        endcase
    end
    
    assign o_wr_completed = r_cur_state == INITIAL_STATE;
        
endmodule
`default_nettype wire
