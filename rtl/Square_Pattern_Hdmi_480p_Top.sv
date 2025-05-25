`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 09:26:31 AM
// Design Name: 
// Module Name: Hdmi_Pattern_Top
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


module Square_Pattern_Hdmi_480p_Top(
    input i_sys_clk,
    input i_reset,
    output [2:0] tmdsp,
    output [2:0] tmdsn,
    output tmdsp_clk,
    output tmdsn_clk
    );
    
    parameter COORD_BITS = 10;
    parameter COLOUR_BITS = 4;
    
    wire w_clk_250Mhz, w_clk_25Mhz;
    wire w_reset;
    wire w_clk_locked;
    clk_wiz_0 Clk_Generator_Inst
    (
       // Clock out ports
       .o_clk_250MHz(w_clk_250MHz),
       .o_clk_25MHz(w_clk_25MHz),
       // Status and control signals
       .reset(i_reset),
       .i_locked(),
       // Clock in ports
       .i_clk(i_sys_clk));
    
    wire [COORD_BITS-1:0] w_sx, w_sy;
    wire w_hsync, w_vsync;
    wire w_de;
    Display_480p Display_Inst (
    .i_clk_pxl(w_clk_25MHz),
    .i_reset(!w_clk_locked),
    .o_sx(w_sx),
    .o_sy(w_sy),
    .o_hsync(w_hsync),
    .o_vsync(w_vsync),
    .o_de(w_de)
    );
    
    logic v_square;
    logic [COLOUR_BITS-1:0] v_paint_r, v_paint_g, v_paint_b;
    logic [COLOUR_BITS-1:0] v_display_r, v_display_g, v_display_b;
    always_comb begin
        v_square = (w_sx > 220 && w_sx < 420) && (w_sy > 140 && w_sy < 340);
        
        // White outside the square, blue inside the square.
        v_paint_r = (v_square) ? 4'hF : 4'h1;
        v_paint_g = (v_square) ? 4'hF : 4'h3;
        v_paint_b = (v_square) ? 4'hF : 4'h7;
        
        // Should be black during blanking.
        v_display_r = (w_de) ? v_paint_r : 4'h0;
        v_display_g = (w_de) ? v_paint_g : 4'h0;
        v_display_b = (w_de) ? v_paint_b : 4'h0;
    end
    
    always @(posedge w_clk_250MHz) begin
    
    end
    
endmodule
