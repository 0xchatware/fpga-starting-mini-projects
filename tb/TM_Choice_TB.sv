`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 09:16:54 PM
// Design Name: 
// Module Name: TM_Choice_TB
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


module TM_Choice_TB();
    localparam CLOCK_PERIOD = 8; // 125MHz == 8ns
    logic clk_tb, reset;
    
    logic [7:0] r_data;
    logic [8:0] r_qm;
    TM_Choice UUT(
    .i_data(r_data),
    .o_qm(r_qm)
    );
    
    assign #(CLOCK_PERIOD/2) clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 1;
        reset = 1;
        #CLOCK_PERIOD;
        
        reset = 0;
        r_data = 8'b1111_1110;
        #(CLOCK_PERIOD * 2);
        assert (r_qm == 9'b0_0000_0000) $display("First test passes!");
        
        r_data = 8'b0000_0001;
        #CLOCK_PERIOD;
        assert (r_qm == 9'b1_1111_1111) $display("Second test passes!");
        $finish;
    end
endmodule
