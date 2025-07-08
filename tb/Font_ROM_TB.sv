`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2025 10:02:56 AM
// Design Name: 
// Module Name: Font_ROM_TB
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


module Font_ROM_TB();
    localparam CLK_PERIOD = 40; // 25MHz = 40ns
    localparam COLOUR_BITS = 8;
    localparam ACTIVE_H_PIXELS = 1280;
    localparam H_FRONT_PORCH = 110;
    localparam H_SYNCH_WIDTH = 40;
    localparam H_BACK_PORCH = 220;
    localparam TOTAL_HOR_PIXEL = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNCH_WIDTH + H_BACK_PORCH;
    localparam ACTIVE_LINES = 720;
    localparam V_FRONT_PORCH = 5;
    localparam V_SYNCH_WIDTH = 5;
    localparam V_BACK_PORCH = 20;
    localparam TOTAL_VER_PIXEL = ACTIVE_LINES + V_FRONT_PORCH + V_SYNCH_WIDTH + V_BACK_PORCH;
    localparam FPS = 60;
    localparam NUM_CHAR = 256;
    
    localparam LINES_TABLE = NUM_CHAR;
    localparam COLUMNS_TABLE = 8 * 16;
    localparam FONT_FILE = "VGA8_testing.F16.mem";
    
    logic clk, reset;
    assign #(CLK_PERIOD/2) clk = ~clk;
    
    logic [$clog2(TOTAL_HOR_PIXEL)-1:0] sx, x;
    logic [$clog2(TOTAL_VER_PIXEL)-1:0] sy, y;
    logic hsync, vsync, de, nf;

    Video_Signal_Generator #(.ACTIVE_H_PIXELS(ACTIVE_H_PIXELS),
                            .H_FRONT_PORCH(H_FRONT_PORCH),
                            .H_SYNCH_WIDTH(H_SYNCH_WIDTH),
                            .H_BACK_PORCH(H_BACK_PORCH),
                            .ACTIVE_LINES(ACTIVE_LINES),
                            .V_FRONT_PORCH(V_FRONT_PORCH),
                            .V_SYNCH_WIDTH(V_SYNCH_WIDTH),
                            .V_BACK_PORCH(V_BACK_PORCH),
                            .FPS(FPS)
    ) Video_Signal_Inst(
        .i_clk_pxl(clk),
        .i_reset(reset),
        .o_sx(sx),
        .o_sy(sy),
        .o_hsync(hsync),
        .o_vsync(vsync),
        .o_de(de),
        .o_nf(nf),
        .o_fc(fc));
        
    logic [$clog2(NUM_CHAR)-1:0] character;
    logic data, en;
    
    Font_ROM#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
              .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
              .NUM_CHAR(NUM_CHAR)
    ) UUT (
        .i_clk(clk),
        .i_character(character),
        .i_sx(sx),
        .i_sy(sy),
        .i_x(x),
        .i_y(y),
        .i_en(en),
        .o_data(data));
    
    reg [COLUMNS_TABLE-1:0] font_data [0:LINES_TABLE-1];
    logic [COLUMNS_TABLE-1:0] cur_data;
    logic [$clog2(COLUMNS_TABLE)-1:0] cur_pos;
    logic cur_byte;
    
    initial begin
        $display("Loading char into table.");
        $readmemh(FONT_FILE, font_data);
    end
    
    initial begin
        clk = 1;
        en = 0;
        x = 0;
        y = 0;
        #(CLK_PERIOD * 2);
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
        
        character = "A";
        en = 1;
        cur_data = font_data[character];
        $display("Value of 'A': 0x%0h", cur_data);
        #(CLK_PERIOD);
        
        for (int i = 0; i < TOTAL_VER_PIXEL * TOTAL_HOR_PIXEL; i++) begin
            if (sx <= 7 && sy <= 15) begin
                cur_pos = sy * 8 + sx;
                cur_byte = cur_data[COLUMNS_TABLE-cur_pos-1];
                #(CLK_PERIOD/2);
                assert (cur_byte == data) $display("Success!");
                    else $error("Values don't match for character 'A', sx=0x%0h, sy=0x%0h, data=%0b, cur_byte[sx]=%0b.",
                                sx, sy, data, cur_byte);
                #(CLK_PERIOD/2);
            end else begin
                #(CLK_PERIOD);
            end
        end
        $finish;
    end
    
    
endmodule
