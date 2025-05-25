`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 12:17:55 PM
// Design Name: 
// Module Name: Clock_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Inspired from https://github.com/projf/projf-explore/blob/main/lib/clock/xc7/clock_tb.sv
// 
//////////////////////////////////////////////////////////////////////////////////


module Clock_TB();
    parameter CLOCK_PERIOD = 10;
    
    logic clk_125MHz, reset, locked;
    logic clk_25MHz, clk_250MHz;
    
    clk_wiz_0 instance_name
   (
    .o_clk_250MHz(clk_250MHz),     // output o_clk_250MHz
    .o_clk_25MHz(clk_25MHz),     // output o_clk_25MHz
    .reset(reset), // input reset
    .i_locked(locked),
    .i_clk(clk_125MHz)      // input i_clk
    );
    
    assign #(CLOCK_PERIOD/2) clk_125MHz = ~clk_125MHz;
    
    initial begin
        clk_125MHz = 1;
        reset = 1;
        #(CLOCK_PERIOD)
        
        reset = 0;
        
        #(CLOCK_PERIOD * 100);
        $finish;
    end
endmodule
