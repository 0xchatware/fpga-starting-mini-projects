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
    input wire i_next_round,
    input wire [1:0] i_control,
    input wire i_nf,
    input wire [$clog2(SCREEN_WIDTH)-1:0] i_hcount,
    input wire [$clog2(SCREEN_HEIGHT)-1:0] i_vcount,
    output logic [7:0] o_red,
    output logic [7:0] o_green,
    output logic [7:0] o_blue
  );
     
  localparam PADDLE_WIDTH = 16;
  localparam PADDLE_HEIGHT = 128;
  localparam PUCK_WIDTH = 50;
  localparam PUCK_HEIGHT = 50;
  localparam GAME_WIDTH = 1280;
  localparam GAME_HEIGHT = 720;
  localparam PADDLE_SPEED = 1;
  localparam PUCK_SPEED = 3;

  logic [$clog2(SCREEN_WIDTH)-1:0] puck_x, paddle1_x, paddle2_x; //puck x location, paddle x location
  logic [$clog2(SCREEN_HEIGHT)-1:0] puck_y, paddle1_y, paddle2_y; //puck y location, paddle y location
  logic [7:0] puck_r, puck_g, puck_b; //puck red, green, blue (from block sprite)
  logic [7:0] paddle1_r, paddle1_g, paddle1_b; //paddle colors from its block sprite)
  logic [7:0] paddle2_r, paddle2_g, paddle2_b;

  logic dir_x, dir_y; //use for direction of movement: 1 going positive, 0 going negative

  logic up1, down1; //up1 down1 from buttons
  logic game_over; //signal to indicate game over (0 on game reset, 1 during play)
  assign up1 = i_control[1]; //up1 control
  assign down1 = i_control[0]; //down1 control

  Block_Sprite #(.WIDTH(PADDLE_WIDTH), .HEIGHT(PADDLE_HEIGHT), 
                 .SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT))
  paddle_player_1(
    .i_hcount(i_hcount),
    .i_vcount(i_vcount),
    .i_x(paddle1_x),
    .i_y(paddle1_y),
    .o_red(paddle1_r),
    .o_green(paddle1_g),
    .o_blue(paddle1_b));

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
    
  Block_Sprite #(.WIDTH(PADDLE_WIDTH), .HEIGHT(PADDLE_HEIGHT), 
                 .SCREEN_WIDTH(SCREEN_WIDTH), .SCREEN_HEIGHT(SCREEN_HEIGHT))
  paddle_player_2(
    .i_hcount(i_hcount),
    .i_vcount(i_vcount),
    .i_x(paddle2_x),
    .i_y(paddle2_y),
    .o_red(paddle2_r),
    .o_green(paddle2_g),
    .o_blue(paddle2_b));

  assign o_red = puck_r | paddle1_r | paddle2_r; //merge color contributions from puck and paddle
  assign o_green =  puck_g | paddle1_g | paddle2_g; //merge color contribuations from puck and paddle
  assign o_blue = puck_b | paddle1_b | paddle2_b; //merge color contributsion from puck and paddle

  logic puck1_overlap; //one bit signal indicating if puck and paddle overlap
  assign puck1_overlap = (puck_y >= paddle1_y && puck_y < (paddle1_y+PADDLE_HEIGHT)) ||
                        ((puck_y+PUCK_HEIGHT) >= paddle1_y && (puck_y+PUCK_HEIGHT) < (paddle1_y+PADDLE_HEIGHT));
                        
  logic puck2_overlap;
  assign puck2_overlap = (puck_y >= paddle2_y && puck_y < (paddle2_y+PADDLE_HEIGHT)) ||
                        ((puck_y+PUCK_HEIGHT) >= paddle2_y && (puck_y+PUCK_HEIGHT) < (paddle2_y+PADDLE_HEIGHT));

  always_ff @(posedge i_pixel_clk)begin
    if (i_rst)begin
      //start puck in center of screen
      puck_x <= GAME_WIDTH/2-PUCK_WIDTH/2;
      puck_y <= GAME_HEIGHT/2 - PUCK_HEIGHT/2;
      dir_x <= i_hcount[0]; //start at pseudorandom direction
      dir_y <= i_hcount[1]; //start with pseudorandom direction
      //start paddle in center of left half of screen
      paddle1_x <= 0;
      paddle1_y <= GAME_HEIGHT/2 - PADDLE_HEIGHT/2;
      paddle2_x <= (GAME_WIDTH-PADDLE_WIDTH);
      paddle2_y <= GAME_HEIGHT/2 - PADDLE_HEIGHT/2;
      game_over <= 0;
    end else begin
      if (~game_over && i_nf) begin
        if (up1 && ~down1) begin
            paddle1_y <= paddle1_y < PADDLE_SPEED ? 0 : paddle1_y-PADDLE_SPEED;
        end else if (~up1 && down1) begin
            paddle1_y <= (paddle1_y+PADDLE_SPEED) <= (GAME_HEIGHT-PADDLE_HEIGHT) ?
                        (paddle1_y+PADDLE_SPEED) : (GAME_HEIGHT-PADDLE_HEIGHT);
        end
        
        if (paddle2_y > puck_y) begin
            paddle2_y <= paddle2_y < PADDLE_SPEED ? 0 : paddle2_y-PADDLE_SPEED;
        end else if (paddle2_y < (PUCK_HEIGHT+puck_y)) begin
            paddle2_y <= (paddle2_y+PADDLE_SPEED) <= (GAME_HEIGHT-PADDLE_HEIGHT) ? 
                         (paddle2_y+PADDLE_SPEED) : (GAME_HEIGHT-PADDLE_HEIGHT);
        end
        
        if ((puck_x < PADDLE_WIDTH && !puck1_overlap) || (puck_x > (GAME_WIDTH-PUCK_WIDTH-PADDLE_WIDTH) && !puck2_overlap)) begin
            game_over <= 1;
        end else if (puck_x < PADDLE_WIDTH || puck_x > (GAME_WIDTH-PUCK_WIDTH-PADDLE_WIDTH)) begin
            dir_x = ~dir_x;
        end else if (puck_y < PUCK_SPEED || puck_y > (GAME_HEIGHT-PUCK_HEIGHT)) begin
            dir_y = ~dir_y;
        end
        
        puck_x = dir_x ? puck_x+PUCK_SPEED : puck_x-PUCK_SPEED;
        puck_y = dir_y ? puck_y-PUCK_SPEED : puck_y+PUCK_SPEED;
      end
    end
  end
endmodule
`default_nettype wire
