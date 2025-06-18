`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 12:23:49 PM
// Design Name: 
// Module Name: RAM_TB
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


module RAM_TB();
    localparam RD_CLK_PERIOD = 8; // 8ns == 125MHz
    localparam WR_CLK_PERIOD = 40; // 40ns == 25MHz
    localparam WIDTH = 8;
    localparam DEPTH = 256;
    
    logic wr_clk, rd_clk;
    logic wr_dv, rd_en, rd_dv;
    logic [$clog2(DEPTH)-1:0] wr_addr, rd_addr;
    logic [WIDTH-1:0] wr_data, rd_data;
    
    initial wr_clk = 0;
    initial rd_clk = 0;
    initial wr_dv = 0;
    initial rd_en = 0;
    initial wr_addr = 0;
    initial rd_addr = 0;
    initial wr_data = 0;
    
    assign #(WR_CLK_PERIOD / 2) wr_clk = ~wr_clk;
    assign #(RD_CLK_PERIOD / 2) rd_clk = ~rd_clk;
    
    RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) UUT (   
    // Write
    .i_wr_clk(wr_clk),
    .i_wr_dv(wr_dv),
    .i_wr_addr(wr_addr),
    .i_wr_data(wr_data),
    // Read
    .i_rd_clk(rd_clk),
    .i_rd_en(rd_en),
    .i_rd_addr(rd_addr),
    .o_rd_data(rd_data),
    .o_rd_dv(rd_dv)
    );
    
    initial begin
        for(int i = 0; i < DEPTH; i++) begin
            wr_data = DEPTH - i;
            wr_addr = i;
            #WR_CLK_PERIOD;
            
            wr_dv = 1;
            #WR_CLK_PERIOD;
            
            wr_dv = 0;
            #WR_CLK_PERIOD;
        end
        $finish;
    end
    
    initial begin
        #(WR_CLK_PERIOD * DEPTH);
        for(int i = 0; i < DEPTH; i++) begin
            #RD_CLK_PERIOD;
            rd_addr = i;
            rd_en = 1;
            #RD_CLK_PERIOD;
            
            wait (rd_dv == 1);
            rd_en = 0;
            #RD_CLK_PERIOD;
        end
    end
    
endmodule
