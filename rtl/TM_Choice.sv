`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 08:58:51 PM
// Design Name: 
// Module Name: TM_Choice
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Reference from https://fpga.mit.edu/6205/F24/assignments/hdmi/tmds_tm
// 
//////////////////////////////////////////////////////////////////////////////////


module TM_Choice(
    input wire [7:0] i_data,
    output logic [8:0] o_qm     // intermidiate value
    );
    
    int sum = 0; // between 0 to 7
    assign o_qm[0] = i_data[0];
    always@(*) begin
        sum = $countbits(i_data, 1'b1);
        if (sum > 4 || (sum == 4 && i_data[0] == 0)) begin
            for (int i = 1; i < 8; i++) begin
                o_qm[i] = ~(i_data[i] ^ o_qm[i-1]);
            end
            o_qm[8] = 0;
        end
        else begin
            for (int i = 1; i < 8; i++) begin
                o_qm[i] = i_data[i] ^ o_qm[i-1];
            end
            o_qm[8] = 1;
        end
        sum = 0;
    end
endmodule
