import numpy as np
import struct
 
from PIL import Image
import os

dataset_path = 'C:/Users/Administrator/Desktop/MNIST/'  # 需要修改的路径:解压的数据集所在文件夹
data_file = dataset_path + 't10k-images.idx3-ubyte' 
 
# It's 7840016B, but we should set to 7840000B
data_file_size = 7840016
data_file_size = str(data_file_size - 16) + 'B'
 
data_buf = open(data_file, 'rb').read()
 
magic, numImages, numRows, numColumns = struct.unpack_from('>IIII', data_buf, 0)
datas = struct.unpack_from('>' + data_file_size, data_buf, struct.calcsize('>IIII'))
datas = np.array(datas).astype(np.uint8).reshape(numImages, 1, numRows, numColumns)
 
label_file = dataset_path + 't10k-labels.idx1-ubyte'
 
# It's 10008B, but we should set to 10000B
label_file_size = 10008
label_file_size = str(label_file_size - 8) + 'B'
 
label_buf = open(label_file, 'rb').read()
 
magic, numLabels = struct.unpack_from('>II', label_buf, 0)
labels = struct.unpack_from('>' + label_file_size, label_buf, struct.calcsize('>II'))
labels = np.array(labels).astype(np.int64)
 
test_path = dataset_path + 'mnist_test' 
if not os.path.exists(test_path):
    os.mkdir(test_path)

# 新建 0~9 十个文件夹，存放转换后的图片
for i in range(10):
    file_name = test_path + os.sep + str(i)
    if not os.path.exists(file_name):
        os.mkdir(file_name)
 
for ii in range(numLabels):
    img = Image.fromarray(datas[ii, 0, 0:28, 0:28])
    label = labels[ii]
    file_name = test_path + os.sep + str(label) + os.sep  + str(ii) + '.png'
    img.save(file_name)