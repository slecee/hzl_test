# 实现mnist的dataset 和dataloader
# 1.解析所有的training images、Labels，test images Labels
# 2.定义dataset，传入的数据是images和labels
# 3.定义dataLoader，此时为每个batch打包images和Labels
# 4. 写一个简单的程序，加载并使用dataLoader。 (区分training和test)

import numpy as np
import matplotlib.pyplot as plt

# def parse_mnist_labels_file(file):
#     # 解析标签的函数，返回值是标签
#     with open (file, 'rb') as f:
#         data = f.read() # 一次性读入，对内存有一定的压力

#     # magic number，num of items
#     magic_number, num_of_items = np.frombuffer(data, dtype=">i" ,count = 2, offset=0)
#     # 断言
#     # 如果cond不满足，则程序抛出assert异常，消息是message
#     # assert cond, message
#     assert magic_number == 2049,'Invalid labels file.'
#     items = np.frombuffer(data, dtype=np.uint8, count=-1, offset =8).astype(np.int32)
#     assert num_of_items == len(items),'Invalid items count.'
#     return items


# def parse_mnist_images_file(file):
#     # 解析标签的函数，返回值是标签
#     with open (file, 'rb') as f:
#         data = f.read() # 一次性读入，对内存有一定的压力

#     # magic number,num of images,rows,columns
#     magic_number, num_of_images, rows, columns = np.frombuffer(data, dtype=">i" ,count = 4, offset=0)
#     # 断言
#     # 如果cond不满足，则程序抛出assert异常，消息是message
#     # assert cond, message
#     assert magic_number == 2051,'Invalid images file.'
#     pixels = np.frombuffer(data, dtype=np.uint8, count=-1, offset =16)
#     images = pixels.reshape(num_of_images,rows,columns)
#     return images


class MnistDataset:
    ''' '''
    def __init__(self,images_files:str,labels_files:str):
        self.images = self.parse_mnist_images_file(images_files)
        self.labels = self.parse_mnist_labels_file(labels_files)
        assert len(self.images) == len(self.labels), 'Create mnist dataset failed.'

    def __len__(self):
        return len(self.images)
    
    def __getitem__(self,index):
        return self.images[index], self.labels[index]


    # 因为这个函数他是功能性质的，不需要使用为self的任何信息
    # 所以我们可以期待它是一个类的函数，静态方法
    @staticmethod
    def parse_mnist_labels_file(file):
    # 解析标签的函数，返回值是标签
        with open (file, 'rb') as f:
            data = f.read() # 一次性读入，对内存有一定的压力

        # magic number，num of items
        magic_number, num_of_items = np.frombuffer(data, dtype=">i" ,count = 2, offset=0)
        # 断言
        # 如果cond不满足，则程序抛出assert异常，消息是message
        # assert cond, message
        assert magic_number == 2049,'Invalid labels file.'
        items = np.frombuffer(data, dtype=np.uint8, count=-1, offset =8).astype(np.int32)
        assert num_of_items == len(items),'Invalid items count.'
        return items
    
    @staticmethod
    def parse_mnist_images_file(file):
    # 解析标签的函数，返回值是标签
        with open (file, 'rb') as f:
            data = f.read() # 一次性读入，对内存有一定的压力

        # magic number,num of images,rows,columns
        magic_number, num_of_images, rows, columns = np.frombuffer(data, dtype=">i" ,count = 4, offset=0)
        # 断言
        # 如果cond不满足，则程序抛出assert异常，消息是message
        # assert cond, message
        assert magic_number == 2051,'Invalid images file.'
        pixels = np.frombuffer(data, dtype=np.uint8, count=-1, offset =16)
        images = pixels.reshape(num_of_images,rows,columns)
        return images

class DataloaderIteration(object):
    '''辅助'''
    def __init__(self,dataloader):
        self.dataloader = dataloader
        self.cursor = 0

        self.indexes = np.arange(len(self.dataloader.dataset))
        np.random.shuffle(self.indexes)

        def __next__(self):
            # 随机抓取一批图像和标签
            begin = self.cursor
            end = begin + self.dataloader.batch.size 
            if end > len(self.dataloader.dataset):
                # 迭代到结尾了
                raise StopIteration()
            
            self.cursor = end
            batched_data = []
            for index in self.indexes[begin:end]:
                batched_data.append(self.dataloader.dataset[index])
            # 预期输出3个images一组，3个label一组（现在是列表）
            # 进一步升级，numpy可以把ndarray拼在一起 3*28*28
            return [np.stack(item,axis=0) for item in list(zip(*batched_data))] 
            

class Dataloader(object):
    
    def __init__(self,dataset,batch_size):
        self.dataset = dataset
        self.batch_size = batch_size

    def __iter__(self):
        return DataloaderIteration(self)
    
if __name__ == '__main__':
    dataset = MnistDataset()
    dataloader = Dataloader(dataset, 3)
    for images,labels in dataloader:
        print(images.shape)
        print(labels.shape)

        plt.title(f'label is {labels[0]}')
        plt.imshow(images[0])
        plt.show()