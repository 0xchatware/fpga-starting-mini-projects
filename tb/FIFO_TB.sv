`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 01:40:17 PM
// Design Name: 
// Module Name: FIFO_TB
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


module FIFO_TB();

    localparam CLK_PERIOD = 8; // 8ns == 125MHz
    localparam WIDTH = 8;
    localparam DEPTH = 256;
    
    logic clk;
    logic reset;
    logic wr_dv, rd_en, rd_dv;
    logic [WIDTH-1:0] wr_data, rd_data;
    logic af_flag, ae_flag, full, empty;
    
    initial reset = 0;
    initial clk = 0;
    initial wr_dv = 0;
    initial rd_en = 0;
    initial wr_data = 0;
    
    assign #(CLK_PERIOD / 2) clk = ~clk;
    
    FIFO#(.WIDTH(WIDTH), .DEPTH(DEPTH)) UUT (
    .i_clk(clk),
    .i_rst(reset),
    // write  
    .i_wr_dv(wr_dv),
    .i_wr_data(wr_data),
    .i_af_level(DEPTH * 0.4),
    .o_af_flag(af_flag),
    .o_full(full),
    //read
    .i_rd_en(rd_en),
    .o_rd_dv(rd_dv),
    .o_rd_data(rd_data),
    .i_ae_level(DEPTH * 0.4),
    .o_ae_flag(ae_flag),
    .o_empty(empty)
    );
    
    initial begin
        #CLK_PERIOD;
        reset = 1;
        
        #CLK_PERIOD;
        reset = 0;
    
        for(int i = 0; i < DEPTH; i++) begin
            if (full)
                wait (full == 0);
            wr_data = i;
            #CLK_PERIOD;
            
            wr_dv = 1;
            #CLK_PERIOD;
            
            wr_dv = 0;
            #CLK_PERIOD;
        end
        
        wr_data = 'h34;
        #CLK_PERIOD;
        wr_dv = 1;
        #CLK_PERIOD;
        wr_dv = 0;
    end
    
    initial begin
        #(CLK_PERIOD * DEPTH);
        for(int i = 0; i < DEPTH + 1; i++) begin
            if (empty)
                wait (empty == 0);
                
            #CLK_PERIOD;
            rd_en = 1;
            #CLK_PERIOD;
            
            wait (rd_dv == 1);
            rd_en = 0;
            #CLK_PERIOD;
        end
        
        $finish;
    end
    
endmodule
