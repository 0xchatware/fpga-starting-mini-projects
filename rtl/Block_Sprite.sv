`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 10:00:06 PM
// Design Name: 
// Module Name: Block_Sprite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://fpga.mit.edu/6205/F24/assignments/hdmi/pong
// 
//////////////////////////////////////////////////////////////////////////////////


module Block_Sprite#(
  parameter WIDTH=128, HEIGHT=128, COLOR=24'hFF_FF_FF)(
  input wire [10:0] i_hcount,
  input wire [9:0] i_vcount,
  input wire [10:0] i_x,
  input wire [9:0]  i_y,
  output logic [7:0] o_red,
  output logic [7:0] o_green,
  output logic [7:0] o_blue);
 
  logic in_sprite;
  assign in_sprite = ((i_hcount >= i_x && i_hcount < (i_x + WIDTH)) &&
                      (i_vcount >= i_y && i_vcount < (i_y + HEIGHT)));
  always_comb begin
    if (in_sprite) begin
      o_red = COLOR[23:16];
      o_green = COLOR[15:8];
      o_blue = COLOR[7:0];
    end else begin
      o_red = 0;
      o_green = 0;
      o_blue = 0;
    end
  end
endmodule
`default_nettype wire
