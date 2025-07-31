`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2025 12:06:19 PM
// Design Name: 
// Module Name: CORDIC_Algorithm_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: www.xilinx.com/publications/archives/xcell/Xcell79.pdf
// 
//////////////////////////////////////////////////////////////////////////////////


module CORDIC_Algorithm_TB();
    localparam CLK_PERIOD = 8; // 8ns == 125MHz
    localparam BITS = 32;
    localparam N_ITERATION = 12;
    localparam FRAC_BITS = BITS-8;
    
    localparam HYPERBOLIC = -1;
    localparam LINEAR = 0;
    localparam CIRCULAR = 1;
    
    logic clk, rst;
    logic [BITS-1:0] i_x, i_y, i_z, o_x, o_y, o_z;
    logic signed [1:0] mode;
    logic rot_en;
    
    always #(CLK_PERIOD/2) clk = ~clk;

    CORDIC_Algorithm #(.N_ITERATION(N_ITERATION),
                       .INTEGER_BITS(BITS-FRAC_BITS), // Q6.26
                       .FRACTIONAL_BITS(FRAC_BITS)) UUT (
        .i_clk(clk),
        .i_rst(rst),
        .i_x(i_x),
        .i_y(i_y),
        .i_z(i_z), //theta
        .i_mode(mode),
        .i_rot_en(rot_en), // if not i_rot_en, vectoring mode
        .o_x(o_x),
        .o_y(o_y),
        .o_z(o_z)
    );
    
    real vec_x [0:5] = {6, 81, 3, 1.34, 3, 0};
    real vec_y [0:5] = {5, 10, 3, 1.04, 3, 1};
    real vec_z [0:5] = {3, 3, 0.76, 3, 0.234, 3};
    int vec_mode [0:5] = {LINEAR, LINEAR, HYPERBOLIC, HYPERBOLIC,
                          CIRCULAR, CIRCULAR};
    real res;
    initial begin
        clk = 0;
        rst = 0;
        i_x = 0;
        i_y = 0;
        i_z = 0;
        mode = 0;
        rot_en = 0;
        
        #(CLK_PERIOD);
        rst = 1;
        #(CLK_PERIOD);
        rst = 0;
        
        for (int i=0; i<$size(vec_x); i++) begin
            i_x = $rtoi(vec_x[i] * 2**FRAC_BITS);
            i_y = $rtoi(vec_y[i] * 2**FRAC_BITS);
            i_z = $rtoi(vec_z[i] * 2**FRAC_BITS);
            mode = vec_mode[i];
            rot_en = (1 + i) % 2;
            #(CLK_PERIOD);
        end
        
        #(CLK_PERIOD * (N_ITERATION - $size(vec_x)))
        
        res = vec_x[0] * vec_y[0];
        assert (res == to_real(o_y)) $display("Success!");
            else $error ("Error on multiplication. Should be %r. Result %r.", res, to_real(o_y));
        #(CLK_PERIOD);
            
        res = vec_y[1] / vec_x[1];
        assert (res == to_real(o_z)) $display("Success!");
            else $error ("Error on division. Should be %f. Result %f.", res, to_real(o_z));
        
        $finish();
    end
    
    function automatic real to_real(input logic [BITS-1:0] num);
        return $itor(num) * 2**-FRAC_BITS;
    endfunction;
    
endmodule
