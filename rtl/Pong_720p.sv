`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 09:47:37 PM
// Design Name: 
// Module Name: Pong
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://fpga.mit.edu/6205/_static/F24/assignments/hdmi/pong/pong.sv
// 
//////////////////////////////////////////////////////////////////////////////////

module Pong_720p #(
    parameter SCREEN_WIDTH=1650, SCREEN_HEIGHT=750)(
    input wire i_pixel_clk,
    input wire i_rst,
    input wire [1:0] i_control,
    input wire i_puck_speed,
    input wire i_paddle_speed,
    input wire i_nf,
    input wire [$clog2(SCREEN_WIDTH)-1:0] i_hcount,
    input wire [$clog2(SCREEN_HEIGHT)-1:0] i_vcount,
    output logic [7:0] o_red,
    output logic [7:0] o_green,
    output logic [7:0] o_blue
  );
     
  localparam PADDLE_WIDTH = 16;
  localparam PADDLE_HEIGHT = 128;
  localparam PUCK_WIDTH = 128;
  localparam PUCK_HEIGHT = 128;
  localparam GAME_WIDTH = 1280;
  localparam GAME_HEIGHT = 720;
  localparam SLOW_SPEED = 1;
  localparam FAST_SPEED = 3;

  logic [$clog2(SCREEN_WIDTH)-1:0] puck_x, paddle_x; //puck x location, paddle x location
  logic [$clog2(SCREEN_HEIGHT)-1:0] puck_y, paddle_y; //puck y location, paddle y location
  logic [7:0] puck_r, puck_g, puck_b; //puck red, green, blue (from block sprite)
  logic [7:0] paddle_r, paddle_g, paddle_b; //paddle colors from its block sprite)

  logic dir_x, dir_y; //use for direction of movement: 1 going positive, 0 going negative

  logic up, down; //up down from buttons
  logic game_over; //signal to indicate game over (0 on game reset, 1 during play)
  assign up = i_control[1]; //up control
  assign down = i_control[0]; //down control

  Block_Sprite #(.WIDTH(PADDLE_WIDTH), .HEIGHT(PADDLE_HEIGHT), 
                 .SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT))
  paddle(
    .i_hcount(i_hcount),
    .i_vcount(i_vcount),
    .i_x(paddle_x),
    .i_y(paddle_y),
    .o_red(paddle_r),
    .o_green(paddle_g),
    .o_blue(paddle_b));

  Block_Sprite #(.WIDTH(PUCK_WIDTH), .HEIGHT(PUCK_HEIGHT), 
                 .SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT))
  puck(
    .i_hcount(i_hcount),
    .i_vcount(i_vcount),
    .i_x(puck_x),
    .i_y(puck_y),
    .o_red(puck_r),
    .o_green(puck_g),
    .o_blue(puck_b));

  assign o_red = puck_r | paddle_r; //merge color contributions from puck and paddle
  assign o_green =  puck_g | paddle_g; //merge color contribuations from puck and paddle
  assign o_blue = puck_b | paddle_b; //merge color contributsion from puck and paddle

  logic puck_overlap; //one bit signal indicating if puck and paddle overlap
  assign puck_overlap = (puck_y >= paddle_y && puck_y < (paddle_y+PADDLE_HEIGHT)) ||
                        ((puck_y+PUCK_HEIGHT) >= paddle_y && (puck_y+PUCK_HEIGHT) < (paddle_y+PADDLE_HEIGHT));

  logic [$clog2(FAST_SPEED)-1:0] puck_speed, paddle_speed;
  assign puck_speed = i_puck_speed ? FAST_SPEED : SLOW_SPEED;
  assign paddle_speed = i_paddle_speed ? FAST_SPEED : SLOW_SPEED;
  always_ff @(posedge i_pixel_clk)begin
    if (i_rst)begin
      //start puck in center of screen
      puck_x <= GAME_WIDTH/2-PUCK_WIDTH/2;
      puck_y <= GAME_HEIGHT/2 - PUCK_HEIGHT/2;
      dir_x <= i_hcount[0]; //start at pseudorandom direction
      dir_y <= i_hcount[1]; //start with pseudorandom direction
      //start paddle in center of left half of screen
      paddle_x <= 0;
      paddle_y <= GAME_HEIGHT/2 - PADDLE_HEIGHT/2;
      game_over <= 0;
    end else begin
      if (~game_over) begin
        //your logic here.
        if (i_nf) begin
            if (up && ~down) begin
                paddle_y <= paddle_y < paddle_speed ? 0 : paddle_y - paddle_speed;
            end else if (~up && down) begin
                paddle_y <= (paddle_y + paddle_speed) < (GAME_HEIGHT-PADDLE_HEIGHT) ?
                            (paddle_y + paddle_speed) : (GAME_HEIGHT-PADDLE_HEIGHT);
            end
            
            if (puck_x < PADDLE_WIDTH && !puck_overlap) begin
                game_over <= 1;
            end else if (puck_x < PADDLE_WIDTH || puck_x > (GAME_WIDTH-PUCK_WIDTH)) begin
                dir_x = ~dir_x;
            end else if (puck_y < puck_speed || puck_y > (GAME_HEIGHT-PUCK_HEIGHT)) begin
                dir_y = ~dir_y;
            end
            
            puck_x = dir_x ? puck_x+puck_speed : puck_x-puck_speed;
            puck_y = dir_y ? puck_y-puck_speed : puck_y+puck_speed;
        end
      end
    end
  end
endmodule
`default_nettype wire
