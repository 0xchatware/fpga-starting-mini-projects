`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 04:46:40 PM
// Design Name: 
// Module Name: RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://github.com/nandland/getting-started-with-fpgas/blob/main/chapter06/memory/Verilog/source/RAM_2Port.v
// 
//////////////////////////////////////////////////////////////////////////////////


module RAM#(parameter WIDTH = 8,
            parameter DEPTH = 256,
            parameter FILE = "",
            parameter INITIAL_ZERO = 0)(   
    // Write
    input wire i_wr_clk,
    input wire i_wr_dv, // data valid
    input wire [$clog2(DEPTH)-1:0] i_wr_addr,
    input wire [WIDTH-1:0]         i_wr_data,
    // Read
    input wire i_rd_clk,
    input wire i_rd_en,
    input wire [$clog2(DEPTH)-1:0] i_rd_addr,
    output logic [WIDTH-1:0]  o_rd_data,
    output logic o_rd_dv // data valid
    );
    
    logic [WIDTH-1:0] r_mem [0:DEPTH-1];
    
    initial begin
        if (FILE != "") begin
            $readmemh(FILE, r_mem);
        end else if (INITIAL_ZERO == 1) begin
            for (int i = 0; i < DEPTH; i++)
                r_mem[i] <= 0;
        end
    end
        
    always_ff@(posedge i_wr_clk) begin
        if (i_wr_dv) begin
            r_mem[i_wr_addr] <= i_wr_data;
        end
    end
    
    always_ff@(posedge i_rd_clk) begin
        o_rd_data <= r_mem[i_rd_addr];
        o_rd_dv <= i_rd_en;
    end
    
endmodule
`default_nettype wire
