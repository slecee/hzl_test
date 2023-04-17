## 线性回归
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import load_boston

class LinearRegression(object):
    def __init__(self):
        self.w = 0 # 斜率 是个向量
        self.b = 0 # 截距 是个数值
        self.sqrLoss = 0            #最小均方误差
        self.trainSet = 0           #训练集特征
        self.label = 0              #训练集标签
        self.learning_rate = None   #学习率
        self.n_iters = None         #实际迭代次数
        self.lossList = []          #梯度下降每轮迭代的误差列表

    def train(self, X, y, method, learning_rate=0.1, n_iters=1000):
        if X.ndim < 2:
            raise ValueError("X must be 2D array-like!")
        self.trainSet = X
        self.label = y
        if method.lower() == "matrix":
            self.__train_matrix()
        elif method.lower() == "gradient":
            self.__train_gradient(learning_rate, n_iters)
        else:
            raise ValueError("method value not found!")
        return

    def __train_formula(self):
        # np.linalg.inv(np.dot(X.T,X)) X.T y = w
        # 这里的x需要加1列1，放在首列或者尾列都可以
        # 数据处理放在前面，比如标准化等等
        n_samples, n_features = self.trainSet.shape
        X = self.trainSet
        y = self.label
        #合并w和b，在X尾部添加一列全是1的特征
        X2 = np.hstack((X, np.ones((n_samples, 1))))
        #求w和b
        temp = np.linalg.inv(np.dot(X2.T,X2))
        what = np.dot(np.dot(temp,X2.T),y)
        self.w = what[:-1]
        self.b = what[-1]
        self.sqrLoss = np.power((y-np.dot(X2,what).flatten()), 2).sum()
        return
    
    def __train_gradient(self, learning_rate, n_iters, minloss=1.0e-6):
        n_samples, n_features = self.trainSet.shape
        X = self.trainSet
        y = self.label
        #初始化迭代次数为0，初始化w0，b0为1，初始化误差平方和以及迭代误差之差
        n = 0
        w = np.ones(n_features)
        b = 1
        sqrLoss0 = np.power((y-np.dot(X,w).flatten()-b), 2).sum()
        self.lossList.append(sqrLoss0)
        deltaLoss = np.inf
        while (n<n_iters) and (sqrLoss0>minloss) and (abs(deltaLoss)>minloss):
            #求w和b的梯度
            ypredict = np.dot(X, w) + b
            gradient_w = -1.*np.dot((y - ypredict), X)/n_samples
            gradient_b = -1.*sum(y - ypredict)/n_samples
            #更新w和b
            w = w - learning_rate * gradient_w
            b = b - learning_rate * gradient_b
            #求更新后的误差和更新前后的误差之差
            sqrLoss1 = np.power((y-np.dot(X,w).flatten()-b), 2).sum()
            deltaLoss = sqrLoss0 - sqrLoss1
            sqrLoss0 = sqrLoss1
            self.lossList.append(sqrLoss0)
            n += 1
        print("第{}次迭代，损失平方和为{}，损失前后差为{}".format(n, sqrLoss0, deltaLoss))
        self.w = w
        self.b = b
        self.sqrLoss = sqrLoss0
        self.learning_rate = learning_rate
        self.n_iters = n+1
        return
    

if __name__ == "__main__":
    X, y = load_boston(True)
    #将特征X标准化，方便收敛
    X = (X - X.mean(axis=0))/X.std(axis=0)
    #矩阵法求解
    lr1 = LinearRegression()
    lr1.train(X, y, method='Matrix')
    print("【矩阵法】\nw:{}, b:{}, square loss:{}".format(lr1.w, lr1.b, lr1.sqrLoss))
    #梯度下降法求解
    lr2 = LinearRegression()
    lr2.train(X, y, method='Gradient', learning_rate=0.1, n_iters=5000)
    print("【梯度下降法】\nw:{}, b:{}, square loss:{}".format(lr2.w, lr2.b, lr2.sqrLoss))
    #画梯度下降的误差下降图
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.plot(range(lr2.n_iters), lr2.lossList, linewidth=3)
    ax.set_title("Square Loss")
    plt.show()