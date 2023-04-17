# for i in range(10):
#     print(i)

# iteration 迭代器，干迭代这件事的主体
# 必须具备__next__这个特殊函数
# next(g)等同于调用了 g.__next__()
# 可选代对象iterable:
# 必须具备:__iter__这个特殊函数，并只返回一个iteration对象

class Range(object):
    def __init__(self, start, stop, step):
        self.start = start
        self.stop = stop
        self.step = step
        self.value = self.start


    def __iter__(self):
        return self

    def __next__(self):
        # 每执行一次next，要返回一个值（相当于生成器中生成一个值的概念）
        # 如果没有下一个了，通过StopIteration告诉我
        if self.value < self.stop:
            old_value = self.value
            self.value = self.value + self.step
            return old_value
        
        raise StopIteration()

for i in Range(0,5,1):
    print(i)

# 跟下面一样的
r = Range(0,5,1)
iteration = iter(r)
# iteration = r.__iter__()

print(next(iteration))
# print(iteration.__next__())
print(next(iteration))
print(next(iteration))
print(next(iteration))
print(next(iteration))
try:
    print(next(iteration))
except StopIteration as e:
    pass