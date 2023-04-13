# install.packages('glmnet')
library(glmnet)
graphics.off()  # clear all graphs
rm(list = ls()) 

# 示例数据准备
N = 500 # 观测数
p = 20  # 变量数

# X variable
X = matrix(rnorm(N*p), ncol=p)

# 计算标准化前的均值和标准差
colMeans(X)    # mean
apply(X,2,sd)  # standard deviation

# 标准化
X = scale(X,center = T,scale = T)

# 计算标准化后的均值和标准差
colMeans(X)    # mean
apply(X,2,sd)  # standard deviation

#——————————————-
# Y variable
#——————————————-
beta = c( 0.15, -0.33,  0.25, -0.25, 0.05,rep(0, p/2-5), 
          -0.25,  0.12, -0.125, rep(0, p/2-3))

# Y variable, standardized Y
y = X%*%beta + rnorm(N, sd=0.5)
y = scale(y)


# Model
# 当lambda = 0.01
lambda <- 0.01
# lasso
la.eq <- glmnet(X, y, lambda=lambda, 
                family='gaussian', 
                intercept = F, alpha=1) 
# 当alpha设置为0则为ridge回归，将alpha设置为0和1之间则为elastic net     
# 系数结果 (lambda=0.01)
la.eq$beta[,1]

# Lasso筛选变量动态过程图
la.eq <- glmnet(X, y, family="gaussian", 
                intercept = F, alpha=1) 
# plot
plot(la.eq,xvar = "lambda", label = F)
# 也可以用下面的方法绘制
#matplot(log(la.eq$lambda), t(la.eq$beta),
#               type="l", main="Lasso", lwd=2)


mod_cv <- cv.glmnet(x=X, y=y, family="gaussian", # 默认nfolds = 10
                    intercept = F, alpha=1)

plot(mod_cv) 


# lambda.min : the λ at which the minimal MSE is achieved.

# lambda.1se : the largest λ at which the MSE is within one standard error of the minimal MSE.
print(paste(mod_cv$lambda.min,
            log(mod_cv$lambda.min)))
print(paste(mod_cv$lambda.1se,
            log(mod_cv$lambda.1se)))

# 这里我们以lambda.min为最优 λ
best_lambda <- mod_cv$lambda.min
best_lambda
# 最终模型的系数估计
#find coefficients of best model
best_model <- glmnet(X, y, alpha = 1, lambda = best_lambda)
coef(best_model)
