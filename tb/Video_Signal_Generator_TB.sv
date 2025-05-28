`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 11:15:09 AM
// Design Name: 
// Module Name: Video_Signal_Generator_TB
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


module Video_Signal_Generator_TB();
    localparam CLK_PERIOD = 8; // 8ns == 125MHz
    localparam FRAMES_PER_SECOND = 60;
    localparam PIXELS_COUNT = 800;
    localparam LINES_COUNT = 525;
    logic clk_tb, reset, locked;
    logic [$clog2(PIXELS_COUNT)-1:0] sx;
    logic [$clog2(LINES_COUNT)-1:0] sy;
    logic hsync, vsync, de;
    logic nf;
    logic [$clog2(FRAMES_PER_SECOND)-1:0] fc;
    
    logic clk_25MHz, clk_250MHz;
    
    clk_wiz_0 Clock_Gen_Inst
   (
    .o_clk_250MHz(clk_250MHz),     // output o_clk_250MHz
    .o_clk_25MHz(clk_25MHz),     // output o_clk_25MHz
    .reset(reset), // input reset
    .i_locked(locked),
    .i_clk(clk_tb)      // input i_clk
    );
    
    Video_Signal_Generator UUT (
    .i_clk_pxl(clk_25MHz),
    .i_reset(!locked),
    .o_sx(sx),
    .o_sy(sy),
    .o_hsync(hsync),
    .o_vsync(vsync),
    .o_de(de),   // data enable
    .o_nf(nf),   // is next frame
    .o_fc(fc)    // frame counter
    );
    
    assign #(CLK_PERIOD / 2) clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 1;
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        
        wait (fc == 5'h1);
        $finish;
    end
endmodule
