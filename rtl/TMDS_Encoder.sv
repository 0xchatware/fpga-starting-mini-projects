`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 10:35:31 PM
// Design Name: 
// Module Name: TMDS_Encoder
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


module TMDS_Encoder(
    input wire i_clk,
    input wire i_rst,
    input wire [7:0] i_data,    // video data (red, green or blue)
    input wire [1:0] i_control, //for blue set to {vs,hs}, else will be 0
    input wire i_ve,            // video data enable, to choose between control or video signal
    output logic [9:0] o_tmds
    );
    
    logic [8:0] r_qm;
    TM_Choice TM_Choice_Inst (
        .i_data(i_data),
        .o_qm(r_qm));
    
    reg [4:0] r_tally;
    reg [7:0] r_last_data;
    bit r_first;
    int num_ones = 0;
    always@(posedge i_clk) begin
        if (i_rst) begin
            r_tally = 0;
            o_tmds = 0;
            r_last_data = 8'bXXXX_XXXX;
            r_first = 1;
        end
        else if (i_ve) begin
            r_first = 1;
            r_tally = 0;
            r_last_data = 8'bXXXX_XXXX;
            case (i_control)
                2'b00: o_tmds = 10'b1101010100;
                2'b01: o_tmds = 10'b0010101011;
                2'b10: o_tmds = 10'b0101010100;
                2'b11: o_tmds = 10'b1010101011;
            endcase
        end
        else begin
            if (r_first || r_last_data != i_data) begin
                num_ones = $countbits(r_qm[7:0], 1'b1);
                if ((r_tally[4] == 0 && num_ones > 4 && r_tally != 0) || (r_tally[4] == 1 && num_ones < 4)) begin
                     o_tmds[9:0] = {1'b1, r_qm[8], ~r_qm[7:0]};
                end
                else begin
                    o_tmds[9:0] = {1'b0, r_qm};
                end
                num_ones = $countbits(o_tmds[9:0], 1'b1);
                
                r_tally = r_tally + num_ones - (10 - num_ones);
                
                num_ones = 0;
                r_last_data = i_data;
                r_first = 0;
            end
        end
    end
    
endmodule
