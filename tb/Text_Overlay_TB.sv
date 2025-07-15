`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2025 01:29:41 PM
// Design Name: 
// Module Name: Text_Overlay_TB
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


module Text_Overlay_TB();
    localparam CLK_PERIOD = 40; // 25MHz = 40ns
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
    localparam CHAR_BUFF_ROWS = 2;
    localparam CHAR_BUFF_COLUMNS = 10;
    
    localparam LINES_TABLE = NUM_CHAR;
    localparam COLUMNS_TABLE = 8 * 16;
    localparam FONT_FILE = "VGA8_testing.F16.mem";
    
    logic clk, reset;
    
    logic [$clog2(TOTAL_HOR_PIXEL)-1:0] sx, x, sx_d;
    logic [$clog2(TOTAL_VER_PIXEL)-1:0] sy, y, sy_d;
    logic [$clog2(FPS)-1:0] fc;
    logic hsync, vsync, de, nf;
    
    logic [$clog2(NUM_CHAR)-1:0] character;
    logic [$clog2(COLUMNS_TABLE)-1:0] offset; 
    logic data, rd_en, rd_dv;
    
    string hello_str;
    initial hello_str = "Hello, world!";
    localparam HELLO_STR_SIZE = 13;
    logic [HELLO_STR_SIZE-1:0][7:0] str;
    initial str = "Hello, world!";
    
    string hello_only_str;
    initial hello_only_str = "Hello, hello!";
    logic [HELLO_STR_SIZE-1:0][7:0] str_2;
    initial str_2 = "Hello, hello!";

    int cur_character, cur_pos, cur_char_x, cur_char_y, error_count;
    logic [COLUMNS_TABLE-1:0] cur_data [0:HELLO_STR_SIZE-1]; // questionable
    logic cur_byte;
    
    initial clk = 1;
    initial reset = 0;
    initial rd_en = 0;
    initial x = 67;
    initial y = 14;
    initial cur_byte = 0;
    initial error_count = 0;
    
    assign #(CLK_PERIOD/2) clk = ~clk;
    
    always@(posedge clk) begin : delaying_tests_values
        sx_d <= sx;
        sy_d <= sy;
    end

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
        .i_reset(reset || !rd_dv),
        .o_sx(sx),
        .o_sy(sy),
        .o_hsync(hsync),
        .o_vsync(vsync),
        .o_de(de),
        .o_nf(nf),
        .o_fc(fc));
        
    Text_Overlay#(.HORIZONTAL_WIDTH(TOTAL_HOR_PIXEL),
                  .VERTICAL_WIDTH(TOTAL_VER_PIXEL),
                  .COLUMNS(CHAR_BUFF_COLUMNS),
                  .NUM_CHAR(HELLO_STR_SIZE)
    ) UUT (
        .i_clk(clk),
        .i_characters(str),
        .i_sx(sx),
        .i_sy(sy),
        .i_x(x),
        .i_y(y),
        .i_rd_en(rd_en),
        .o_rd_dv(rd_dv),
        .o_data(data)
    );
    
    logic [COLUMNS_TABLE-1:0] font_data [0:LINES_TABLE-1];
    
    initial begin : set_testing_char_table
        $display("Loading char into table.");
        $readmemh(FONT_FILE, font_data);
    end
    
    initial begin : test_brench
        for (int i = 0; i < CHAR_BUFF_ROWS*CHAR_BUFF_COLUMNS; i++) begin
            cur_data[i] = font_data[" "];
        end
        
        #(CLK_PERIOD * 2);
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
        
        run_test(hello_str);
        
        $display("Changing string value.");
        str = str_2;
        #(CLK_PERIOD);
        
        run_test(hello_only_str);
        
        $finish;
        
    end
    
    task run_test(input string str_arg);
        populate_ram(str_arg);
        wait(rd_dv == 1);
        rd_en = 1;
        error_count = 0;
        
        for (int i = 0; i < TOTAL_VER_PIXEL * TOTAL_HOR_PIXEL; i++) begin
            if (sx >= x && sx < (CHAR_BUFF_COLUMNS*8+x) && sy >= y && sy <= (CHAR_BUFF_ROWS*16+y)) begin
                cur_char_set();
                #(CLK_PERIOD/2);
                if (cur_byte || data) begin
                    assert (cur_byte == data) $display("Success!");
                        else begin 
                            $error("Values don't match for character '%s', sx=0x%0h, sy=0x%0h, data=%0b, cur_byte[sx]=%0b.",
                                    str_arg[cur_character], sx, sy, data, cur_byte);
                            error_count++;
                        end
                end
                #(CLK_PERIOD/2);
            end else begin
                cur_byte = 0;
                #(CLK_PERIOD);
            end
        end
        $display("Error count: %d", error_count);
    endtask
    
    task populate_ram (input string str_arg);
        for (int i = 0; i < str_arg.len(); i++) begin
            character = str_arg[i];
            cur_data[i] = font_data[character];
            $display("Value of '%s': 0x%0h", character, cur_data[i]);
        end
    endtask
    
    task cur_char_set;
        cur_char_x = (sx_d-x)/8;
        cur_char_y = (sy_d-y)/16;
        cur_character = cur_char_x + cur_char_y * CHAR_BUFF_COLUMNS;
        cur_pos = (sy_d-y-cur_char_y*16) * 8 + (sx_d-x-cur_char_x*8);
        offset = COLUMNS_TABLE-cur_pos-1;
        cur_byte = cur_character < HELLO_STR_SIZE ? cur_data[cur_character][offset] : 0;
    endtask

endmodule
