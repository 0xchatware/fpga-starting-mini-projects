import sys
from math import atan, atan, atanh

def main(iterations, int_bits, fra_bits):
    with open('tan.mem', 'w') as f:
        j = 1
        for i in range(iterations):
            val = atan(2**(-i))
            fra = int((val - int(val)) * 2**fra_bits)
            out =  (fra) & create_full_bin(int_bits + fra_bits)
            f.write('0' + hex(out)[2:] + '\n')
            j+=1
            
    with open('tanh.mem', 'w') as f:
        j = 1
        for i in range(iterations):
            val = atanh(2**(-j))
            fra = int((val - int(val)) * 2**fra_bits)
            out =  (fra) & create_full_bin(int_bits + fra_bits)
            f.write('0' + hex(out)[2:] + '\n')
            j+=1
            
    with open('cordic_offset.mem', 'w') as f:
        cur_offset = 0
        k = find_k(1)
        prev_i = 1
        for i in range(iterations):
            if prev_i < k:
                prev_i = i + 1
            else:
                cur_offset += 1
                k = find_k(k)
            f.write('0' + hex(cur_offset)[2:] + '\n')
            
def find_k(i): 
    return 3 * i + 1
            
def create_full_bin(num):
    val = 0
    for i in range(num):
        val += 1 << i
    return val 
                
if __name__ == "__main__":
    if len(sys.argv) >= 3 and int(sys.argv[1]) >= 0 and int(sys.argv[2]) >= 0:
        main(int(sys.argv[1]), 2, int(sys.argv[2]))
    else:
        print("Usage: python cordic_table.py [iteration|int] [fra_bits|int]")