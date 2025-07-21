`timescale 1ns / 1ps
`default_nettype none
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
    
    logic signed [4:0] r_tally;
    int v_num_ones_qm;
    
    assign v_num_ones_qm = $countones(r_qm[7:0]);
    
    always@(posedge i_clk) begin
        if (i_rst) begin
            r_tally <= 0;
            o_tmds <= 0;
        end
        else begin
            if (i_ve) begin
                if ((r_tally[4] == 0 && v_num_ones_qm > 4 && r_tally != 0) || (r_tally[4] == 1 && v_num_ones_qm < 4)) begin
                    o_tmds <= {1'b1, r_qm[8], ~r_qm[7:0]};
                    r_tally <= r_tally + $countones(r_qm[8]) +  (8 - $countones(r_qm[7:0])) + 1 
                                - (10 - ($countones(r_qm[8]) + (8 - $countones(r_qm[7:0])) + 1));
                end
                else begin
                    o_tmds <= {1'b0, r_qm};
                    r_tally <= r_tally + $countones(r_qm) 
                                - (10 - $countones(r_qm));
                end
            end
            else begin
                r_tally <= 0;
                case (i_control)
                    2'b00: o_tmds <= 10'b1101010100;
                    2'b01: o_tmds <= 10'b0010101011;
                    2'b10: o_tmds <= 10'b0101010100;
                    2'b11: o_tmds <= 10'b1010101011;
                endcase
            end
            
        end
    end
endmodule
`default_nettype wire
