# 将 24*24 手写数字图片（png）转为 576 行8bit二进制数据，每个像素8bit。（从左到右，从上到下）
# 需要设置 1，2，3，4四处
# input:经脚本转换后的MNIST数据集，28*28
# output: 24*24 的手写数字 txt文件，一行存储8bit像素数据，一共576行
from PIL import Image 
import numpy as np

path0 = 'C:/Users/Administrator/Desktop/pic/24/' # 1 输入图片存储目录
path1 = 'C:/Users/Administrator/Desktop/pic/24/' # 2 输出 txt 存储目录
input_size  = 28 # 输入图片大小
output_size = 24 # 输出图片大小

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

# 读取.png文件，此时image为一个np.array数组
image = Image.open(path0 + '0.png') # 3 图片名称
image_arr = image.resize((output_size,output_size)) # 先将28*28输入图像缩放为 24*24 
image_arr = np.array(image_arr) # 再转化成numpy数组，二维数组，8bit数据  0-255 （无符号数据）
image_arr = image_arr.astype(int) # float -> int
# print(image_arr)

f = open(path1 + "0.txt",'w')  # 4 输出txt文件名称
for i in range (output_size):
    for j in range(output_size):
        f.write(dec2bin(image_arr[i][j]))
        f.write("\n") # 一行一个8bit像素数据
f.close()