`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2025 11:17:38 AM
// Design Name: 
// Module Name: CORDIC_Algorithm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Linear rot : y = x * z
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CORDIC_Algorithm #(parameter N_ITERATION=12, // best practice, number of frac bits == iteration
                          parameter INTEGER_BITS=2, // signed bit included
                          parameter FRACTIONAL_BITS=30,
                          parameter BITS=INTEGER_BITS+FRACTIONAL_BITS)(
        input wire i_clk,
        input wire i_rst,
        input wire signed [BITS-1:0] i_x,
        input wire signed [BITS-1:0] i_y,
        input wire signed [BITS-1:0] i_z,
        input wire signed [1:0] i_mode,
        input wire i_rot_en, // if not i_rot_en, vectoring mode
        output wire signed [BITS-1:0] o_x,
        output wire signed [BITS-1:0] o_y,
        output wire signed [BITS-1:0] o_z
    );
    
    localparam HYPERBOLIC = -1;
    localparam LINEAR = 0;
    localparam CIRCULAR = 1;
    
    localparam TWO_FRACTIONAL = int_to_fixed(2);
    localparam ONE_FRACTIONAL = int_to_fixed(1);
    localparam AN = (BITS-1)'(int'(0.6072529350088812561694 * 2**FRACTIONAL_BITS));
    
    localparam TAN_FILE = "tan.mem";
    localparam TANH_FILE = "tanh.mem";
    logic signed [BITS-1:0] r_tan_mem [0:N_ITERATION-1];
    logic signed [BITS-1:0] r_tanh_mem [0:N_ITERATION-1];
    initial begin
        if (TAN_FILE != "")
            $readmemh(TAN_FILE, r_tan_mem);
        
        if (TANH_FILE != "")
            $readmemh(TANH_FILE, r_tanh_mem);
    end
    
    logic signed [BITS-1:0] r_x [0:N_ITERATION];
    logic signed [BITS-1:0] r_y [0:N_ITERATION];
    logic signed [BITS-1:0] r_z [0:N_ITERATION];
    logic signed [1:0] r_mode [0:N_ITERATION];
    logic r_rot_en [0:N_ITERATION];
    generate
        for (genvar i=0; i<=N_ITERATION; i++) begin // i == 0 : INITIAL VALUE
            always@(posedge i_clk) begin
                if (i_rst) begin
                    r_x[i] <= 0;
                    r_y[i] <= 0;
                    r_z[i] <= 0;
                    r_mode[i] <= 0;
                    r_rot_en[i] <= 0;
                end else begin
                    if (i == 0) begin
                        r_mode[i] <= i_mode;
                        r_rot_en[i] <= i_rot_en;
                        case (i_mode)
                            HYPERBOLIC: begin
                                if (i_rot_en) begin
                                    r_x[i] <= AN;
                                    r_y[i] <= 0;
                                    r_z[i] <= i_z;
                                end else begin
                                    r_x[i] <= i_x - ONE_FRACTIONAL;
                                    r_y[i] <= i_y + ONE_FRACTIONAL;
                                    r_z[i] <= 0;
                                end
                            end
                            LINEAR: begin
                                if (i_rot_en) begin
                                    r_x[i] <= i_x;
                                    r_y[i] <= 0;
                                    r_z[i] <= i_z;
                                end else begin
                                    r_x[i] <= i_x;
                                    r_y[i] <= i_y;
                                    r_z[i] <= 0;
                                end
                            end
                            CIRCULAR: begin
                                if (i_rot_en) begin
                                    r_x[i] <= AN;
                                    r_y[i] <= 0;
                                    r_z[i] <= i_z;
                                end else begin
                                    r_x[i] <= i_x;
                                    r_y[i] <= ONE_FRACTIONAL;
                                    r_z[i] <= 0;
                                end
                            end
                        endcase
                    end else begin                        
                        case(r_mode[i-1])
                            HYPERBOLIC: begin
                                r_x[i] <= r_x[i-1] + (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_y[i-1]) >>> i);
                                r_y[i] <= r_y[i-1] + (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_x[i-1]) >>> i);
                                r_z[i] <= r_z[i-1] - get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_tanh_mem[i-1]);
                            end
                            LINEAR: begin
                                r_x[i] <= r_x[i-1];
                                r_y[i] <= r_y[i-1] + (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_x[i-1]) >>> (i-1));
                                r_z[i] <= r_z[i-1] - (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], ONE_FRACTIONAL) >>> (i-1));
                            end
                            CIRCULAR: begin
                                r_x[i] <= r_x[i-1] - (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_y[i-1]) >>> (i-1));
                                r_y[i] <= r_y[i-1] + (get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_x[i-1]) >>> (i-1));
                                r_z[i] <= r_z[i-1] - get_dir(r_rot_en[i-1], r_y[i-1], r_z[i-1], r_tan_mem[i-1]);
                            end 
                        endcase
                        
                        r_mode[i] <= r_mode[i-1];
                        r_rot_en[i] <= r_rot_en[i-1];
                    end
                end
            end
        end
    endgenerate
    
    assign o_x = r_x[N_ITERATION];
    assign o_y = r_y[N_ITERATION];
    assign o_z = r_z[N_ITERATION];
    
    function logic signed [BITS-1:0] get_dir(input logic is_rot_en, 
                           input logic signed [BITS-1:0] y,
                           input logic signed [BITS-1:0] z,
                           input logic signed [BITS-1:0] value);
        return (is_rot_en && z < 0) || (!is_rot_en && y >= 0) ? -value : value;
    endfunction
    
    function logic signed [BITS-1:0] int_to_fixed(input logic [INTEGER_BITS-1:0] val);
        return (BITS)'(val <<< FRACTIONAL_BITS);
    endfunction
    
endmodule
`default_nettype wire
