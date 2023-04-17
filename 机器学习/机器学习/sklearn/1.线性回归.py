from sklearn import linear_model # 加载线性回归
from sklearn import datasets # sklearn下载好的数据
from sklearn.model_selection import train_test_split # 划分数据集
from sklearn.metrics import mean_squared_error, r2_score # 评价指标
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm # 为了显示r2 p值等

# 数据最重要的是整理，很费功夫
# 生成数据

# X = np.linspace(0,10) # 不行，必须两维[[1],[2],[3]]是可以的
# y = 0.5*X + 3
# plt.plot(X,y)
# plt.show()

# 加载数据
# data = datasets.load_diabetes() #是个字典
# X = data.data
# y = data.target

X,y = datasets.load_diabetes(return_X_y=True) # 只返回X和y，其他不要
# load已经下载好的
# fetch自己下载
# make生成

# 导入数据

# 划分测试集与训练集
# X = np.linspace(0,10,51)
# shuffled_index = np.random.permutation(len(X))
# x1 = X[shuffled_index]
# split_index = int(len(X) * 0.8)
# x_train = x1[:split_index]

df = pd.read_excel('D:/project_new/机器学习/机器学习/sklearn/dataset/客户价值数据表.xlsx')
print(df.head())
X = df[['历史贷款金额', '贷款次数', '学历', '月收入', '性别']]
Y = df['客户价值']

regr = linear_model.LinearRegression()
regr.fit(X, Y)

print('各系数：' + str(regr.coef_))
print('常数项k0：' + str(regr.intercept_))
# X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2,random_state=123)
# reg = linear_model.LinearRegression()
# model = reg.fit(X_train,y_train)
# print(model.coef_)
# print(model.intercept_)

# 显示t值p值
X2 = sm.add_constant(X)
est = sm.OLS(Y, X2).fit()
print(est.summary())  


## 正则化