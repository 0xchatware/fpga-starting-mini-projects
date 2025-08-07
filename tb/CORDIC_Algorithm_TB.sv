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
//                      https://digitalsystemdesign.in/wp-content/uploads/2019/01/cordic1.pdf
// 
//////////////////////////////////////////////////////////////////////////////////


module CORDIC_Algorithm_TB();
    localparam CLK_PERIOD = 8; // 8ns == 125MHz
    localparam BITS = 32;
    localparam INT_BITS = 2;
    localparam FRAC_BITS = BITS-INT_BITS;
    localparam N_ITERATION = FRAC_BITS;
    
    localparam HYPERBOLIC = -1;
    localparam LINEAR = 0;
    localparam CIRCULAR = 1;
    
    localparam NONE = 10.0;
    
    logic clk, rst;
    logic signed [BITS-1:0] i_x, i_y, i_z, o_x, o_y, o_z;
    logic signed [1:0] mode;
    logic rot_en;
    
    always #(CLK_PERIOD/2) clk = ~clk;

    CORDIC_Algorithm #(.N_ITERATION(N_ITERATION),
                       .INTEGER_BITS(INT_BITS), // Q2.30 sign included
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
    
    localparam TESTS = 7;
    real vec_x [0:TESTS-1] = {0.25, -0.45, 0.87, NONE, NONE, NONE, 1.00};
    real vec_y [0:TESTS-1] = {NONE,  NONE, 0.12, NONE, NONE, NONE, 1.00};
    real vec_z [0:TESTS-1] = {0.15,  0.23, NONE, 1, 0.5, 0.0909, NONE};
    int vec_mode [0:TESTS-1] = {LINEAR, LINEAR, LINEAR, HYPERBOLIC, HYPERBOLIC,
                          CIRCULAR, CIRCULAR};
    bit vec_rot_en [0:TESTS-1] = {1, 1, 0, 1, 0, 1, 0};
    
    real expected [1:0];
    real result [1:0];
    real comp;
    string operation [1:0];
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
            i_x = int'(vec_x[i] * 2**FRAC_BITS);
            i_y = int'(vec_y[i] * 2**FRAC_BITS);
            i_z = int'(vec_z[i] * 2**FRAC_BITS);
            mode = vec_mode[i];
            rot_en = vec_rot_en[i];
            #(CLK_PERIOD);
        end
        
        #(CLK_PERIOD * (N_ITERATION - $size(vec_x)+1))
        
        for (int i=0; i<$size(vec_x); i++) begin
            case (vec_mode[i])
                LINEAR: begin
                    if (vec_rot_en[i]) begin
                        expected[0] = vec_x[i] * vec_z[i];
                        result[0] = to_real(o_y);
                        operation[0] = "Multiplication";
                        operation[1] = "None";
                    end else begin
                        expected[0] = vec_y[i] / vec_x[i];
                        result[0] = to_real(o_z);
                        operation[0] = "Division";
                        operation[1] = "None";
                    end
                end
                HYPERBOLIC: begin
                    if (vec_rot_en[i]) begin
                        expected[0] = $cosh(vec_z[i]);
                        result[0] = to_real(o_x);
                        operation[0] = "Cosh";
                        
                        expected[1] = $sinh(vec_z[i]);
                        result[1] = to_real(o_y);
                        operation[1] = "Sinh";
                    end else begin
                        expected[0] = $atanh(vec_z[i]);
                        result[0] = to_real(o_z);
                        operation[0] = "Atanh"; 
                        operation[1] = "None";
                    end
                end
                CIRCULAR: begin
                    if (vec_rot_en[i]) begin
                        expected[0] = $cos(vec_z[i]);
                        result[0] = to_real(o_x);
                        operation[0] = "Cos";
                        
                        expected[1] = $sin(vec_z[i]);
                        result[1] = to_real(o_y);
                        operation[1] = "Sin";
                    end else begin
                        expected[0] = $atan(vec_y[i] / vec_x[i]);
                        result[0] = to_real(o_z);
                        operation[0] = "Atan"; // range [-pi/2, pi/2]
                        
                        expected[1] = $sqrt(vec_x[i]**2 - vec_y[i]**2);
                        result[1] = to_real(o_x);
                        operation[1] = "Sqrt(x**2 * y**2)";
                    end
                end
            endcase
            for (int j=0; j < 2; j++) begin
                if (operation[j] == "None")
                    continue;
                comp = (expected[j] - result[j]) < 0 ? -(expected[j] - result[j]) : (expected[j] - result[j]);
                assert (comp < 0.001) $display("%s is success! Expected: %f. Result %f.",
                                                                operation[j],
                                                                expected[j],
                                                                result[j]);
                            else $error ("%s error: Should be %f. Result %f. Difference %f.",
                                            operation[j],
                                            expected[j], 
                                            result[j],
                                            comp);
            end
            #(CLK_PERIOD);
        end
        
        $finish();
    end
    
    function automatic real to_real(input logic signed [BITS-1:0] num);
        return real'(num) / (2.0**FRAC_BITS);
    endfunction;
    
endmodule
