# 将 MNIST 28*28 手写数字图片（png）转为 784行8bit二进制数据，每个像素8bit。（从左到右，从上到下）
import matplotlib.image as mpimg # mpimg 用于读取图片
import numpy as np

path0 = 'C:/Users/Administrator/Desktop/pic/0/' # 输入图片存储目录
path1 = 'C:/Users/Administrator/Desktop/pic/1/' # 输出 txt 存储目录
size = 28 # 输入图片大小 28*28

# 十进制转二进制，8bit
def dec2bin(dec_num, bit_wide=8):
    _, bin_num_abs = bin(dec_num).split('b')
    if len(bin_num_abs) > bit_wide:
        raise ValueError           # 数值超出bit_wide长度所能表示的范围
    else:
        if dec_num >= 0:
            bin_num = bin_num_abs.rjust(bit_wide, '0')
        else:
            _, bin_num = bin(2**bit_wide + dec_num).split('b')
    return bin_num

# 读取.png文件，此时pic为一个np.array数组，每个像素值为0-1
pic = mpimg.imread(path0 + '3.png') 
# 转为 8bit数据  0-127
pic = pic*127 
pic = pic.astype(int) # float -> int

f = open(path1 + "test_bin.txt",'w') 
for i in range (size):
    for j in range(size):
        f.write(dec2bin(pic[i][j]))
        f.write("\n") # 一行一个8bit像素数据
f.close()