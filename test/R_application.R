library(mlr3verse)
library(tidyverse)
library(MASS)
library(ISLR)

head(Boston)
boxplot(Boston)


boxplot <- boxplot(Boston$crim,outline = T,log= "y")
boxplot$stats #什么含义？？？
# 数据除离群值之外的最小值，最大值

summary(Boston$crim)
#  Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.00632  0.08204  0.25651  3.61352  3.67708 88.97620 

sifeiwei <- quantile(Boston$crim, probs = c(0.25,0.75), na.rm = T)
#   25%      75%    
#  0.082045 3.677083 
row_max <- sifeiwei[[2]] + 1.5 * (sifeiwei[[2]] - sifeiwei[[1]]) # 常用为1.5,更宽松一点可以设为3
# 9.069639
row_min <- sifeiwei[[1]] - 1.5 * (sifeiwei[[2]] - sifeiwei[[1]])
# -5.310511

abline(h=boxplot$stats[1,],lwd=1,col=2,asp = 2,lty = 2)
text(1.25,boxplot$stats[1,], "minimum=0.00632", col = 2,adj=c(0,-0.4))

abline(h=boxplot$stats[2,],lwd=1,col=2,asp = 2,lty = 2)
text(1.25,boxplot$stats[2,], "Q1=0.08199", col = 2,adj=c(0,-0.4))

abline(h=boxplot$stats[3,],lwd=1,col=2,asp = 2,lty = 2)
text(1.25,boxplot$stats[3,], "median=0.25651", col = 2,adj=c(0,-0.4))

abline(h=boxplot$stats[4,],lwd=1,col=2,asp = 2,lty = 2)
text(1.25,boxplot$stats[4,], "Q3=3.67822", col = 2,adj=c(0,-0.4))

abline(h=boxplot$stats[5,],lwd=1,col=2,asp = 2,lty = 2)
text(1.25,boxplot$stats[5,], "maximum=8.98296", col = 2,adj=c(0,-0.4))


a <- c(-100,-1,-10,-2,5,9,13,1,1,3,5,7,9,11,28,34,56,76,44,65,87,45,43,23,78)
boxplot1 <- boxplot(a)
boxplot1$stats 
# 数据除离群值之外的最小值，最大值

lm.fit=lm(medv~lstat,data=Boston)
summary(lm.fit)


sd(Boston$lstat)
length(Boston$lstat)