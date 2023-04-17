# 求解一个数平方根
import matplotlib.pyplot as plt
import numpy as np

# 暴力求解
# 首先开始猜测一个值t
# 评估t与sqrt(x)的差异-----------也就是t^2 与x的差异diff
# 达到一定的精度时停止 比如diff要小于0.0001
# 开始循环，找到更合适的t，并更新

def difference(x,y):
    return (x*x - y)**2  
# 为了循环可以终止，这个差异必须为正值，不过平方会放大差异


def sqrt_(x):
    t = x/2
    diff = difference(t,x)
    while diff > 0.00001:
        if difference(t-0.001,x) < difference(t+0.001,x):
            t -= 0.001
        else:
            t += 0.001
        diff = difference(t,x)
    return t

print(sqrt_(2))


# 上述方法的问题t的更新频率是固定的，下降的会非常慢，所以有没有更好更快的办法呢
# 二分法，牛顿法，梯度下降法（开始下降的快，后面下降的慢）

# difference的函数图像
# 定义 x 变量的范围 (-3，3) 数量 50 
x = np.linspace(0,2,50)
y = (x**2 - 2)**2
plt.plot(x,y,color='red',linewidth=1.0,linestyle='--')
# 设置 x，y 轴的范围以及 label 标注
plt.xlim(0,2)
plt.ylim(0,4)
plt.xlabel('x')
plt.ylabel('y')
# 显示图像
plt.show()

# 从图像可知，上述初始值设置的是1，每次更新的步长为0.001，这是固定的！！
# 我们的目的明显是diff = 0，固定太慢了！
# 梯度下降来了（注意凸函数会非常好，而不是凸函数需要我们去考虑）！！也就是把更新的步长改成函数 
# 在取值的导数 t1 = t0 - dy/dx （梯度下降，新函数的取值变小了）
# t1 = t0 + dy/dx （梯度上升，新函数的取值变大了）
# 通过函数图像可以验证


def gradient(t, x): # 每次均不一样！！！
    return 4*(t*t-x)*t

def loss(x,y):  # 损失函数
    return (x*x - y)**2  
# 为了循环可以终止，这个差异必须为正值，不过平方会放大差异


def sqrt_1(x):
    t = x/2
    alpha = 0.01 
    # 学习率，防止迭代步长下降过快，
    # 主要是gradient计算出来有时会较大，比如2，而t0与最优值差异可能只在0.2以内
    diff = loss(t,x)
    while diff > 0.0000001:
        # if difference(t-0.001,x) < difference(t+0.001,x):
        #     t = t - grad
        # else:
        #     t = t + grad
        t = t - alpha*gradient(t,x)
        diff = loss(t,x)
    return t

print(sqrt_1(2))

# 1.4139999999999544
# 1.4141064784726314