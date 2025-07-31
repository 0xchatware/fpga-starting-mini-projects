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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CORDIC_Algorithm #(parameter N_ITERATION=12,
                          parameter INTEGER_BITS=8, // signed bit included
                          parameter FRACTIONAL_BITS=8,
                          parameter FIXED_POINT_BITS=INTEGER_BITS+FRACTIONAL_BITS)(
        input wire i_clk,
        input wire i_rst,
        input wire [FIXED_POINT_BITS-1:0] i_x,
        input wire [FIXED_POINT_BITS-1:0] i_y,
        input wire [FIXED_POINT_BITS-1:0] i_z,
        input wire signed [1:0] i_mode,
        input wire i_rot_en, // if not i_rot_en, vectoring mode
        output wire [FIXED_POINT_BITS-1:0] o_x,
        output wire [FIXED_POINT_BITS-1:0] o_y,
        output wire [FIXED_POINT_BITS-1:0] o_z
    );
    
    localparam HYPERBOLIC = -1;
    localparam LINEAR = 0;
    localparam CIRCULAR = 1;
    
    localparam TWO_FRACTIONAL = (FIXED_POINT_BITS)'(2 << FRACTIONAL_BITS);
    localparam ONE_FRACTIONAL = (FIXED_POINT_BITS)'(1 << FRACTIONAL_BITS);
    
    localparam TAN_FILE = "tan.mem";
    localparam TANH_FILE = "tanh.mem";
    logic [FIXED_POINT_BITS-1:0] r_tan_mem [0:N_ITERATION-1];
    logic [FIXED_POINT_BITS-1:0] r_tanh_mem [0:N_ITERATION-1];
    initial begin
        if (TAN_FILE != "")
            $readmemh(TAN_FILE, r_tan_mem);
        
        if (TANH_FILE != "")
            $readmemh(TANH_FILE, r_tanh_mem);
    end
    
    logic [FIXED_POINT_BITS-1:0] r_x [0:N_ITERATION-1];
    logic [FIXED_POINT_BITS-1:0] r_y [0:N_ITERATION-1];
    logic [FIXED_POINT_BITS-1:0] r_z [0:N_ITERATION-1];
    logic signed [1:0] r_mode [0:N_ITERATION-1];
    logic r_rot_en [0:N_ITERATION-1];
    generate
        for (genvar i=0; i<N_ITERATION; i++) begin
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
                                    r_x[i] <= 0;
                                    r_y[i] <= calc_an();
                                    r_z[i] <= i_z;
                                end else begin
                                    r_x[i] <= i_x;
                                    r_y[i] <= i_y;
                                    r_z[i] <= 0;
                                end
                            end
                            LINEAR: begin
                                if (i_rot_en) begin
                                    r_x[i] <= 0;
                                    r_y[i] <= calc_an();
                                    r_z[i] <= i_z;
                                end else begin
                                    r_x[i] <= i_x - 1;
                                    r_y[i] <= i_y + 1;
                                    r_z[i] <= 0;
                                end
                            end
                            CIRCULAR: begin
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
                        endcase
                    end else begin
                        r_x[i] <= r_x[i-1] - r_mode[i-1] * r_y[i-1] * 2**i * 
                                  ((r_rot_en[i-1] && r_z[i-1] < 0) || (!r_rot_en[i-1] && r_y[i-1] < 0) ? -1 : 1);
                        r_y[i] <= r_y[i-1] + r_x[i-1] * 2**i *
                                  ((r_rot_en[i-1] && r_z[i-1] < 0) || (!r_rot_en[i-1] && r_y[i-1] < 0) ? -1 : 1);
                        
                        case(r_mode[i-1])
                            HYPERBOLIC: begin
                                r_z[i] <= r_z[i-1] - r_tanh_mem[i-1] * 
                                          ((r_rot_en[i-1] && r_z[i-1] < 0) || (!r_rot_en[i-1] && r_y[i-1] < 0) ? -1 : 1);
                            end
                            LINEAR: begin
                                r_z[i] <= r_z[i-1] - 2**i * 
                                          ((r_rot_en[i-1] && r_z[i-1] < 0) || (!r_rot_en[i-1] && r_y[i-1] < 0) ? -1 : 1);
                            end
                            CIRCULAR: begin
                                r_z[i] <= r_z[i-1] - r_tan_mem[i-1] * 
                                          ((r_rot_en[i-1] && r_z[i-1] < 0) || (!r_rot_en[i-1] && r_y[i-1] < 0) ? -1 : 1);
                            end 
                        endcase
                        
                        r_mode[i] <= r_mode[i-1];
                        r_rot_en[i] <= r_rot_en[i-1];
                    end
                end
            end
        end
    endgenerate
    
    assign o_x = r_x[N_ITERATION-1];
    assign o_y = r_y[N_ITERATION-1];
    assign o_z = r_z[N_ITERATION-1];
    
    function logic [INTEGER_BITS+FRACTIONAL_BITS-1:0] calc_an();
        logic [INTEGER_BITS+FRACTIONAL_BITS-1:0] an;
        for(int i=0; i<N_ITERATION; i++) begin
            an += $sqrt(ONE_FRACTIONAL+TWO_FRACTIONAL>>(2*i));
        end
        return an;
    endfunction
    
endmodule
`default_nettype wire
