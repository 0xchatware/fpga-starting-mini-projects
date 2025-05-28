`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2025 03:17:00 PM
// Design Name: 
// Module Name: TMDS_Serializer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A parallel-to-serial converter for TMDS encoding.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Took from https://fpga.mit.edu/6205/_static/F24/default_files/tmds_serializer.sv
// 
//////////////////////////////////////////////////////////////////////////////////


module TMDS_Serializer(
    input wire i_clk_pixel,
    input wire i_clk_5x,
    input wire i_rst,
    input wire [9:0] i_tmds,
    output logic o_tmds
    );
    
    logic [1:0] v_linker;
    
    logic v_pwup_rst = 1'b1;
    always @(posedge i_clk_pixel) begin
        v_pwup_rst <= 1'b0;
    end
    
     OSERDESE2 #(
      .DATA_RATE_OQ("DDR"),
      .DATA_RATE_TQ("SDR"),
      .DATA_WIDTH(10),
      .SERDES_MODE("MASTER"),
      .TRISTATE_WIDTH(1),
      .TBYTE_CTL("FALSE"),
      .TBYTE_SRC("FALSE")
      ) primary (
          .OQ(o_tmds),
          .OFB(),
          .TQ(),
          .TFB(),
          .SHIFTOUT1(),
          .SHIFTOUT2(),
          .TBYTEOUT(),
          .CLK(i_clk_5x),
          .CLKDIV(i_clk_pixel),
          .D1(i_tmds[0]),
          .D2(i_tmds[1]),
          .D3(i_tmds[2]),
          .D4(i_tmds[3]),
          .D5(i_tmds[4]),
          .D6(i_tmds[5]),
          .D7(i_tmds[6]),
          .D8(i_tmds[7]),
          .TCE(1'b0),
          .OCE(1'b1),
          .TBYTEIN(1'b0),
          .RST(i_rst || v_pwup_rst),
          .SHIFTIN1(v_linker[0]),
          .SHIFTIN2(v_linker[1]),
          .T1(1'b0),
          .T2(1'b0),
          .T3(1'b0),
          .T4(1'b0)
      );
      OSERDESE2 #(
          .DATA_RATE_OQ("DDR"),
          .DATA_RATE_TQ("SDR"),
          .DATA_WIDTH(10),
          .SERDES_MODE("SLAVE"),
          .TRISTATE_WIDTH(1),
          .TBYTE_CTL("FALSE"),
          .TBYTE_SRC("FALSE")
      ) secondary (
          .OQ(),
          .OFB(),
          .TQ(),
          .TFB(),
          .SHIFTOUT1(v_linker[0]),
          .SHIFTOUT2(v_linker[1]),
          .TBYTEOUT(),
          .CLK(i_clk_5x),
          .CLKDIV(i_clk_pixel),
          .D1(1'b0),
          .D2(1'b0),
          .D3(i_tmds[8]),
          .D4(i_tmds[9]),
          .D5(1'b0),
          .D6(1'b0),
          .D7(1'b0),
          .D8(1'b0),
          .TCE(1'b0),
          .OCE(1'b1),
          .TBYTEIN(1'b0),
          .RST(i_rst || v_pwup_rst),
          .SHIFTIN1(1'b0),
          .SHIFTIN2(1'b0),
          .T1(1'b0),
          .T2(1'b0),
          .T3(1'b0),
          .T4(1'b0)
      );
endmodule
`default_nettype wire
