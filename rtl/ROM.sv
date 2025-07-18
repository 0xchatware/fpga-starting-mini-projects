`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2025 02:02:49 PM
// Design Name: 
// Module Name: ROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Inspired from https://github.com/adumont/fpga-font/blob/master/ram.v
// 
//////////////////////////////////////////////////////////////////////////////////


module ROM#(parameter WIDTH=8,
            parameter DEPTH=128,
            parameter FILE="")
(
    input wire i_clk,
    input wire [$clog2(DEPTH)-1:0] i_rd_addr,
    output logic [WIDTH-1:0] o_dout
    );
    
    logic [WIDTH-1:0] r_mem [0:DEPTH-1];
    logic [WIDTH-1:0] r_dout;
    
    initial begin
        if (FILE != "") begin
            $readmemh(FILE, r_mem);
        end
    end
    
    always_ff@(posedge i_clk) begin : read_rom
        o_dout <= r_mem[i_rd_addr];
    end
endmodule
`default_nettype wire
