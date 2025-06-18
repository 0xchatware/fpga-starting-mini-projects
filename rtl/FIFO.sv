`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 02:51:01 PM
// Design Name: 
// Module Name: Fifo
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


module FIFO#(parameter WIDTH = 8,
             parameter DEPTH = 256)(
    input i_clk,
    input i_rst,
    // write  
    input i_wr_dv,
    input [WIDTH-1:0] i_wr_data,
    input [$clog2(DEPTH)-1:0] i_af_level,
    output o_af_flag,
    output o_full,
    //read
    input i_rd_en,
    output o_rd_dv,
    output logic [WIDTH-1:0] o_rd_data,
    input [$clog2(DEPTH)-1:0] i_ae_level,
    output o_ae_flag,
    output o_empty
    );
    
    logic [$clog2(DEPTH)-1:0] r_wr_addr;
    logic [$clog2(DEPTH)-1:0] r_rd_addr;
    logic [$clog2(DEPTH):0] r_counter = 0;
    
    logic [WIDTH-1:0] r_rd_data;
    
    RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) FIFO_Mem_Inst (   
    // Write
    .i_wr_clk(i_clk),
    .i_wr_dv(i_wr_dv),
    .i_wr_addr(r_wr_addr),
    .i_wr_data(i_wr_data),
    // Read
    .i_rd_clk(i_clk),
    .i_rd_en(i_rd_en),
    .i_rd_addr(r_rd_addr),
    .o_rd_data(r_rd_data),
    .o_rd_dv(o_rd_dv)
    );
    
    always@(posedge i_clk) begin
        if (i_rst == 1) begin
            r_wr_addr = 0;
            r_rd_addr = 0;
            r_counter = 0;
        end
        else begin
            if (i_wr_dv) begin
                r_wr_addr = r_wr_addr == DEPTH - 1 ? 0 : r_wr_addr + 1;
            end
            
            if (i_rd_en) begin
                r_rd_addr = r_rd_addr == DEPTH - 1 ? 0 : r_rd_addr + 1;
                o_rd_data = r_rd_data;
            end
            
            if (i_wr_dv && !i_rd_en)
                r_counter++;
            else if (!i_wr_dv && i_rd_en)
                r_counter--;
        end
    end
    
    assign o_full = (r_counter >= DEPTH) || (r_counter == DEPTH-1 && i_wr_dv && !i_rd_en) ? 1 : 0;
    assign o_empty = r_counter == 0;
    assign o_af_flag = (DEPTH - r_counter) < i_af_level;
    assign o_ae_flag = r_counter < i_ae_level;
    
endmodule
