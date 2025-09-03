import sys
from math import atan, atan, atanh, sqrt, ceil

def main(iterations, int_bits, fra_bits):
    bits = int_bits + fra_bits
    with open('cordic_consts.svh', 'w') as f:
        f.write(f"// Generated with \"cordic_table.py {iterations} {int_bits} {fra_bits}\"\n")
        f.write("`ifndef CORDIC_CONSTS_VH\n`define CORDIC_CONSTS_VH\n\n")
        f.write("typedef enum logic signed [1:0] {LINEAR=0, HYPERBOLIC=-1, CIRCULAR=1} e_cordic_mode;\n\n")
        f.write(f"localparam int CORDIC_ITER = {iterations};\n\n")
        
        # tan
        f.write(f"localparam logic signed [{bits - 1}:0] CORDIC_ATAN [0:CORDIC_ITER-1] = {{\n")
        
        values = []
        j = 1
        for i in range(iterations):
            val = atan(2**(-i))
            fra = int((val - int(val)) * 2**fra_bits)
            out =  (fra) & create_full_bin(bits)
            values.append(f"\t{bits}'h{out:0{ceil(bits/4)}x}")
            j+=1
        
        f.write(',\n'.join(values))
        f.write("\n};\n\n")
        
        # tanh
        f.write(f"localparam logic signed [{bits - 1}:0] CORDIC_ATANH [0:CORDIC_ITER-1] = {{\n")
        j = 1
        values.clear()
        for i in range(iterations):
            val = atanh(2**(-j))
            fra = int((val - int(val)) * 2**fra_bits)
            out =  (fra) & create_full_bin(bits)
            values.append(f"\t{bits}'h{out:0{ceil(bits/4)}x}")
            j+=1
        f.write(',\n'.join(values))
        f.write("\n};\n\n")
            
        # offset
        f.write(f"localparam logic [3:0] CORDIC_OFFSET [0:CORDIC_ITER-1] = {{\n")
        values.clear()
        an = 1
        k = find_k(1)
        prev_i = 1
        values.append(f"\t{1}")
        for i in range(iterations-1):
            an *= sqrt(1 - 2**(-2 * prev_i))
            if prev_i < k:
                prev_i = prev_i + 1
            else:
                k = find_k(k)
            values.append(f"\t{prev_i}")
        f.write(',\n'.join(values))
        f.write("\n};\n\n")
        f.write("`endif")
             
def find_k(i): 
    return 3 * i + 1
            
def create_full_bin(num):
    val = 0
    for i in range(num):
        val += 1 << i
    return val 
                
if __name__ == "__main__":
    if len(sys.argv) >= 4 and int(sys.argv[1]) >= 0 and int(sys.argv[2]) >= 2 and int(sys.argv[3]) >= 0:
        main(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))
    else:
        print("Usage: python cordic_table.py [iteration|int] [int_bits|int] [fra_bits|int]")