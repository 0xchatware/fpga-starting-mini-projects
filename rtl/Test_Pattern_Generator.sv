`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2025 01:37:49 PM
// Design Name: 
// Module Name: Test_Pattern_Generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://fpga.mit.edu/6205/F24/assignments/hdmi/hdmi_test
// 
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module Test_Pattern_Generator#(parameter TOTAL_COLUMNS = 1280,
                               parameter TOTAL_ROWS = 720)(
  input wire [1:0] i_sel,
  input wire [$clog2(TOTAL_COLUMNS)-1:0] i_hcount,
  input wire [$clog2(TOTAL_ROWS)-1:0] i_vcount,
  output logic [7:0] o_red,
  output logic [7:0] o_green,
  output logic [7:0] o_blue
  );
  
  localparam ONE_COLOUR_PATTERN = 2'b0;
  localparam CROSS_PATTERN = 2'b01;
  localparam OMBRE_PATTERN = 2'b10;
  localparam MULTI_COLOUR_PATTERN = 2'b11;
  
  logic [1:0] r_state;
  logic [7:0] r_sum;
  
  assign r_state = i_sel;
  
  always_comb begin
    case (r_state)
        ONE_COLOUR_PATTERN : begin
            o_red <= 8'hFF;
            o_green <= 8'h77;
            o_blue <= 8'hAA;
        end
        CROSS_PATTERN : begin
            o_red <= i_hcount == TOTAL_COLUMNS/2 || i_vcount == TOTAL_ROWS/2 
                        ? 8'hFF : 8'h00;
            o_green <= o_red;
            o_blue <= o_red;
        end
        OMBRE_PATTERN : begin
            o_red <= i_hcount[7:0];
            o_green <= o_red;
            o_blue <= o_red;
        end
        MULTI_COLOUR_PATTERN : begin
            o_red <= i_hcount[7:0];
            o_green <= i_vcount[7:0];
            o_blue <= i_hcount[7:0] + i_vcount[7:0];
        end
        default : r_state = ONE_COLOUR_PATTERN;
    endcase
  end
endmodule
`default_nettype wire
