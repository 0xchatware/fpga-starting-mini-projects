// Generated with "cordic_table.py 15 3 30"
`ifndef CORDIC_CONSTS_VH
`define CORDIC_CONSTS_VH

typedef enum logic signed [1:0] {LINEAR=0, HYPERBOLIC=-1, CIRCULAR=1} e_cordic_mode;

localparam int CORDIC_ITER = 15;

localparam logic signed [32:0] CORDIC_ATAN [0:CORDIC_ITER-1] = {
	33'h03243f6a8,
	33'h01dac6705,
	33'h00fadbafc,
	33'h007f56ea6,
	33'h003feab76,
	33'h001ffd55b,
	33'h000fffaaa,
	33'h0007fff55,
	33'h0003fffea,
	33'h0001ffffd,
	33'h0000fffff,
	33'h00007ffff,
	33'h00003ffff,
	33'h00001ffff,
	33'h00000ffff
};

localparam logic signed [32:0] CORDIC_ATANH [0:CORDIC_ITER-1] = {
	33'h02327d4f5,
	33'h01058aefa,
	33'h0080ac48e,
	33'h004015622,
	33'h002002ab1,
	33'h001000555,
	33'h0008000aa,
	33'h000400015,
	33'h000200002,
	33'h000100000,
	33'h000080000,
	33'h000040000,
	33'h000020000,
	33'h000010000,
	33'h000008000
};

localparam logic [3:0] CORDIC_OFFSET [0:CORDIC_ITER-1] = {
	1,
	2,
	3,
	4,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	13
};

`endif