import sys
from math import atan, atan, atanh

def main(type, iterations, int_bits, fra_bits):
    with open(type + '.mem', 'w') as f:
        j = 1
        for i in range(iterations):
            val = atan(2**(-i)) if type == "tan" else atanh(2**(-j))
            fra = int((val - int(val)) * 2**fra_bits)
            out =  (fra) & create_full_bin(int_bits + fra_bits)
            f.write('0' + hex(out)[2:] + '\n')
            j+=1
            
def create_full_bin(num):
    val = 0
    for i in range(num):
        val += 1 << i
    return val 
                
if __name__ == "__main__":
    if len(sys.argv) >= 4 and (sys.argv[1] == "tanh" or sys.argv[1] == "tan") and int(sys.argv[2]) >= 0 and \
        int(sys.argv[3]) >= 0:
        main(sys.argv[1], int(sys.argv[2]), 2, int(sys.argv[3]))
    else:
        print("Usage: python cordic_table.py [tanh/tan] [iteration|int] [fra_bits]")