### dataset 数据集
### dataloader 数据加载器


#### 需求
1. 有一个数据集文件夹，里面会有100w的样本和标签
2. 训练时，通常做法，一次在100w的样本中随机抓取batch个样本进行训练
3. 如果全部抓取完毕，则重新打乱后继续训练


dataset数据集
作用：
1. 储存数据集的信息 self.xxx
2. 获取数据集长度        __len__
3. 获取数据集某特定条目的内容 __getitem__

dataloader 数据加载器
作用：
1. 从数据集随机加载数据，并拼接为一个batch。(两个参数dataset, batch_size)
2. 实现迭代器，可以迭代获取数据内容
```python
# 构建个数据
import numpy as np


class ImageDataset:
    ''' '''
    def __init__(self,raw_data):
        self.raw_data = raw_data

    def __len__(self):
        return len(self.raw_data)

    def __getitem__(self, index):
        image, label = self.raw_data[index]
        return image, label

class DataLoader:
    ''' '''
    def __init__(self, dataset, batch_size):
        self.dataset = dataset
        self.batch_size = batch.size

    def __iter__(self):
        # 每次准备迭代的时候，打乱数据，并清空指针
        # 正常序列
        self.indexes = np.arange(len(self.dataset))
        self.cursor = 0 

        #打乱序列
        np.random.shuffle(self.indexes)
        return self

    def __next__(self):
        # 返回一个batch数据，batch是从dataset中随机抓取的（np.random）
        # 抓batch个数据前，先抓batch个index
        begin = self.cursor
        end = self.cursor + self.batch_size

        if end > len(self.dataset):  ##很重要
            raise StopIteration()

        self.cursor = end
        batched_data = []
        for index in self.indexes[begin:end]:
            item = self.dataset[index]
            batched_data.append(item)
        return batched_data
        
if __name__ = '__main__':
    images = [[f"images{i}",i] for i in range(100)]
    print(images)
    dataset = ImageDataset(images)
    loader = DataLoader(dataset,5)
    for batched_data in loader:
        print (batched_data)
```