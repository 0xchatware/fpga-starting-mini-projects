`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2025 02:41:02 PM
// Design Name: 
// Module Name: ROM_TB
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


module ROM_TB();
    localparam CLK_PERIOD = 8; // 8ns == 125MHz
    localparam WIDTH = 8;
    localparam DEPTH = 256 * 16;
    localparam FILE = "VGA8.F16.mem";
    
    logic clk;
    logic wr_en;
    logic [$clog2(DEPTH)-1:0] wr_addr, rd_addr;
    logic [WIDTH-1:0] wr_data, rd_data;
    
    initial clk = 0;
    initial wr_en = 0;
    initial wr_addr = 0;
    initial rd_addr = 0;
    initial wr_data = 0;
    
    assign #(CLK_PERIOD / 2) clk = ~clk;
    
    ROM#(.WIDTH(WIDTH), .DEPTH(DEPTH), .FILE(FILE)) UUT
    (
        .i_clk(clk),
        .i_wr_addr(wr_addr),
        .i_rd_addr(rd_addr),
        .i_wr_en(wr_en),
        .i_din(wr_data),
        .o_dout(rd_addr));
    
    initial begin
        #(CLK_PERIOD * 10);
        $finish;
    end
endmodule
