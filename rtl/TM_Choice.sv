`timescale 1ns / 1ps
`default_nettype none
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
    
    int sum; // between 0 to 7
    logic[7:0] qm_data;
    logic use_xnor;
    always_comb begin
        sum = $countbits(i_data, 1'b1);
        use_xnor = sum > 4 || (sum == 4 && i_data[0] == 0);
        qm_data[0] = i_data[0];
        for (int i = 1; i < 8; i++) begin
            if (use_xnor) begin
                qm_data[i] = ~(i_data[i] ^ qm_data[i-1]);
            end
            else begin
                qm_data[i] = i_data[i] ^ qm_data[i-1];
            end
        end
        o_qm <= {~use_xnor, qm_data};
    end
endmodule
`default_nettype wire
