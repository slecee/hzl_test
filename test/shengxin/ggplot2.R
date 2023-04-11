options(stringsAsFactors = F,timeout = 200)


install.packages(c("tidyverse", "colorspace", "corrr",  "cowplot",
                   "ggdark", "ggforce", "ggrepel", "ggridges", "ggsci",
                   "ggtext", "ggthemes", "grid", "gridExtra", "patchwork",
                   "rcartocolor", "scico", "showtext", "shiny",
                   "plotly", "highcharter", "echarts4r"))

# install from GitHub since not on CRAN
install.packages(devtools)
devtools::install_github("JohnCoene/charter")


require(tidyverse)
chic <- read_csv("D:/project_new/test/shengxin/chicago-nmmaps.csv")
tibble::glimpse(chic) # 数据的初步认识，几行几列什么类型的数据
summary(chic) # 数据的基本统计信息，最小值最大值四分位数均值
boxplot(chic[,3:7]) 
# ggplot2怎么画这种，查了没找到，我的想法是改数据结构，能不能行还不知道
# 或者在boxpolt上继续修改，	
ggplot(chic[,3:7])+
  geom_boxplot(x = colnames(chic[,3:7]),y = rownames(chic))

head(chic, 10)

#### ggplot2 图层与嵌套------------
g <- ggplot(chic, mapping = aes(x = date, y = temp))
# typeof(g) "list" S3

g + geom_point()

g + geom_line() + geom_point()

g + geom_point(color = "firebrick", shape = "diamond", size = 2)

# aes里面也有color,但是它自己会映射，无法指定
# 无论是"firebrick"还是'1'都是一种颜色,也测试了shape与size，可以试试看
# aes最好只映射X与Y，其他如要用最好是分类变量
# g_ <- ggplot(chic, mapping = aes(x = date, y = temp, color = '1',shape = "diamond", size = 2))+
#   geom_point() 


g + geom_point(color = "firebrick", shape = "diamond", size = 2) +
  geom_line(color = "firebrick", linetype = "dotted", size = .3) 
#点与线的颜色，形状与大小


g + geom_point(color = "firebrick")+
  theme_bw()


# 调整坐标轴
# 比较青睐第一个
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  labs(x = "Year", y = "Temperature (°F)") # 还可以加title

#or
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  xlab("Year") +
  ylab("Temperature (°F)")

# expression 加上花哨的名字，这里是上标，expression函数支持的表达式语法与Latex类似
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  labs(x = "Year", y = expression(paste("Temperature (", degree ~ F, ")"^"(Hey, why should we use metric units?!)")))


# 增加轴与轴标题的距离
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  labs(x = "Year", y = "Temperature (°F)") +# 下面有hjust
  theme(axis.title.x = element_text(vjust = 2, size = 15), # size字体大小，这里上下跳动
        axis.title.y = element_text(vjust = 2, size = 15)) # vjust 水平移动，可以为负往右边去


# ggplot(chic, aes(x = date, y = temp)) +
#   geom_point(color = "firebrick") +
#   labs(x = "Year", y = "Temperature (°F)") +
#   theme(axis.title.x = element_text(vjust = 10, size = 20), 
#         axis.title.y = element_text(vjust = -5, size = 15))


# 指定两个文本元素的边距来改变距离，t和r分别指代top和right,可以试试改成50看看结果
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  labs(x = "Year", y = "Temperature (°F)") +
  theme(axis.title.x = element_text(margin = margin(t = 10), size = 15),
        axis.title.y = element_text(margin = margin(r = 10), size = 15))

# 改变轴标题的美学
ggplot(chic, aes(x = date, y = temp)) +
  geom_point(color = "firebrick") +
  labs(x = "Year", y = "Temperature (°F)") +
  theme(axis.title = element_text(size = 15, color = "firebrick",
                                  face = "italic"))




# 箱型图---------------------


# 数据第一步，认真观察
# 箱型图 核密度聚集在一起，尽量多显示信息
num = '1 1 1 2 2 5 7 9 12 12 25'

num <- str_split(num, pattern = ' ') %>%
  unlist() %>%
  as.numeric() %>%
  mean()  # 7
quantile(num,0.25)

# R中quantile函数的分位数这样计算的 y=p*(n-1)+1
# 以1-10为例，20%分位数为例，首先位数=1+(10-1)*20%=2.8，所以此分位数在
# 第二和第三个数之间，更靠近第三个数(2<2.8<3)，算法：2*0.2+3*0.8=2.8，

# 当 (n+1)/4可以整除时，
# Q1第在(n+1)/4位 1
# Q2第 (n+1)/2位 5
# Q3第(n+1)/4*3位 12
# 均值 7

# 当 (n+1)/4不能整除时
# 举例 数列 1 2 3 4 5 6 7 8
# Q1在 (8+1)/4=2.25位， 介于第二和第三位之间，但是更靠近第二位。所以第二位数权重占75%，
# 第三位数权重占25%。Q1=(2*0.75+3*0.25)/(0.75+0.25)=2.25
# Q2在 (8+1)/2=4.5位，即第4和第5位的平均数，Q2=4.5
# 同理Q3在(8+1)/4*3=6.75位，在第六位和第七位之间，更靠近第7位。所以第7位权重75%，第6位权重25%。
# Q3=(7*0.75+6*0.25)/(0.75+0.25)=6.75

# IQR = Q3-Q1  最小异常值Q1-k(Q3-Q1) 最大异常值Q3+k(Q3-Q1) 一般是1.5 

data_sfw <- apply(data[,4:11], 1,function(row) {
  # row[is.na(row)] <- 0 
  xia <- quantile(row[row != 0],0.25)
  shang <- quantile(row[row != 0],0.75)
  row[row < (xia - 3*(shang - xia))] <- 0 # 常用为1.5,更宽松一点可以设为3
  row[row > (shang + 3*(shang - xia))] <- 0 # 
  return(row)
})



boxplot(tc, col = group_colors[raw_data$sample_group],ylab = "intensity", main = "Total ion current")
boxplot(chic[,3:7]) 
# ggplot2怎么画这种，查了没找到，我的想法是改数据结构，能不能行还不知道
# 或者在boxpolt上继续修改，	
ggplot(chic[,3:7])+  #没用
  geom_boxplot(x = colnames(chic[,3:7]),y = rownames(chic))





ggplot(data,mapping=aes(x=横坐标列,y=纵坐标列,fill=分组列))+ ##设置图形的纵坐标横坐标和分组
  stat_boxplot(mapping=aes(x=横坐标列,y=纵坐标列,fill=分组列),
               geom ="errorbar",                             ##添加箱子的bar为最大、小值
               width=0.15,position=position_dodge(0.8))+     ##bar宽度和组间距
  geom_boxplot(aes(fill=分组列),                             ##分组比较的变量
               position=position_dodge(0.8),                 ##因为分组比较，需设组间距
               width=0.6,                                    ##箱子的宽度
               outlier.color = "white")+                     ##离群值的颜色
  stat_summary(mapping=aes(group=分组列),                    ##分组计算的变量
               fun="mean",                                   ##箱线图添加均值
               geom="point",shape=23,size=3,fill="white",    ##均值图形的设置
               position=position_dodge(0.8))+                ##因为分组比较，需设置两组间距
  scale_fill_manual(values=c("red","white","blue"))+         ##设置分组的颜色,对应fill组数
  scale_y_continuous(limits=c(0,4),                          ##修改y轴的范围
                     breaks=c(1,2,3,4))+                    ##修改y轴刻度位置
  labels=c("A","B","C","D","E")+          ##修改y轴标签的名称
  scale_x_discrete(limits=c("D","C","B","A"),              ##修改x轴标签的顺序
                   labels=c("Z","H","M","R"))+                ##修改x轴标签的名称
  labs(x="X轴新名称",y="Y轴新名称",fill="新图例名称")+        ##修改坐标轴和图例的文本
                     
  theme(panel.background=element_rect(fill='transparent'),   ##去掉底层阴影
        panel.grid=element_blank(),                          ##去掉网格线
        panel.border=element_blank(),                        ##去掉图的边界线
        panel.border=element_rect(fill='transparent',        ##设置图的边界线
                                color='transparent'),
        axis.line=element_line(colour="black",size=0.9),     ##设置坐标轴的线条
        axis.title=element_text(face="bold",size = 13),      ##设置坐标轴文本字体
        axis.title.x=element_blank(),                        ##删除x轴文本               
        axis.text=element_text(face = "bold",size = 10),     ##设置坐标轴标签字体
        axis.ticks=element_line(color='black'),              ##设置坐标轴刻度线
        legend.position=c(0.15, 0.9),                        ##设置图例的位置
        legend.direction = "horizontal",                      ##设置图列标签的排列方式
        legend.title=element_text(face = "bold",size=12),    ##设置图例标题字体
        legend.title=element_blank(),                        ##去掉图例标题         
        legend.text=element_text(face = "bold",size=12),     ##设置图例文本的字体
        legend.background=element_rect(linetype="solid",     ##设置图列的背景和线条颜色
                                        colour ="black"))  
                   






ggplot(data=dfToPlot,aes(x=RELATIONSHIP.0,
                         y=BC_Spec,
                         color=RELATIONSHIP.0))+
  geom_jitter(alpha=0.2,
              position=position_jitterdodge(jitter.width = 0.35, 
                                            jitter.height = 0, 
                                            dodge.width = 0.8))+
  geom_boxplot(alpha=0.2,width=0.45,
               position=position_dodge(width=0.8),
               size=0.75,outlier.colour = NA)+
  geom_violin(alpha=0.2,width=0.9,
              position=position_dodge(width=0.8),
              size=0.75)+
  scale_color_manual(values = cbPalette)+
  theme_classic() +
  theme(legend.position="none") + 
  theme(text = element_text(size=16)) + 
  #ylim(0.0,1.3)+
  ylab("Bray-Curtis distance of Species")+
  #scale_x_discrete(labels=c("A","B","C","D"))+
  annotate("segment", x = 1-0.01, y = 1, xend = 2.01,lineend = "round", 
           yend = 1,size=1,colour="black",arrow = arrow(length = unit(0.02, "npc")))+
  annotate("segment", x = 2.01, y = 1, xend = 0.99,lineend = "round", 
           yend = 1,size=1,colour="black",arrow = arrow(length = unit(0.02, "npc")))+
  annotate("text", x=1.5,y=1.01, 
           label=expression("**"~"FDR"~2.41%*%10^-10),vjust=0)


# 练习-----------------
library(tidyverse)
library(ggpubr)
library(ggsignif)
library(rstatix)

# 构造模拟数据：
data <- data.frame(
  TIME_IA = runif(10, min = 0.05, max = 0.4), # runif函数生成服从均匀分布的随机数,rnorm函数生成正态分布的随机数
  TIME_ISM = runif(10, min = -0.2, max = 0.1),
  TIME_ISS = runif(10, min = 0.1, max = 0.5),
  TIME_IE = runif(10, min = -0.25, max = 0.2),
  TIME_IR = runif(10, min = 0.2, max = 0.6)
)

# 长宽数据转换：
data_long <- pivot_longer(data, cols = everything(),
                          names_to = "group", values_to = "Score")

data_long$group <- factor(data_long$group, levels = colnames(data))
# 计算显著性：
# 批量t检验：
stat.test <- data_long %>%
  wilcox_test(
    Score ~ group,
    p.adjust.method = "bonferroni"
  )


colors <- c('#eb4b3a', "#48bad0", "#1a9781",
                     "#355783", "#ef9a80")
p <- ggplot(data_long)+
                       # 箱线图：
    geom_boxplot(aes(group, Score, color = group))+
                       # 抖动散点：
    geom_jitter(aes(group, Score, color = group), width = 0.01)+
                       # 颜色模式：
    scale_color_manual(values = c('#eb4b3a', "#48bad0", "#1a9781",
                                                              "#355783", "#ef9a80"))+
    xlab("")+
                       # 主题：
    theme_classic()+
    theme(legend.position = "none",
                             # x轴字体、颜色、角度调整：
          axis.text.x = element_text(angle = 90, vjust = 0.5, face = "bold",
          color = colors))
                     
                     # 根据显著性检验结果，添加显著性标记：
x_value <- rep(1:4, 4:1)
y_value <- rep(apply(data, 2, max)[1:4], 4:1) + 0.01
y_value <- y_value + c(0.03*1:4, 0.03*1:3, 0.03*1:2, 0.03)
color_value <- c(colors[2:5], colors[3:5], colors[4:5], colors[5])

for (i in 1:nrow(stat.test)) {
      if (stat.test$p.adj.signif[i] != "ns") {
          y_tmp <- y_value[i]
          p <- p+annotate(geom = "text",
                    label = stat.test$p.adj.signif[i],
                     x = x_value[i],
                     y = y_tmp,
                    color = color_value[i])
                       }
                     }
                     p
                     
                    
                     
                     p_list <- list()
                     for (j in 1:6) {
                       # 构造模拟数据：
                       data <- data.frame(
                         TIME_IA = runif(10, min = 0.05, max = 0.4),
                         TIME_ISM = runif(10, min = -0.2, max = 0.1),
                         TIME_ISS = runif(10, min = 0.1, max = 0.5),
                         TIME_IE = runif(10, min = -0.25, max = 0.2),
                         TIME_IR = runif(10, min = 0.2, max = 0.6)
                       )
                       
                       # 长宽数据转换：
                       data_long <- pivot_longer(data, cols = everything(),
                                                 names_to = "group", values_to = "Score")
                       
                       data_long$group <- factor(data_long$group, levels = colnames(data))
                       # 计算显著性：
                       # 批量t检验：
                       stat.test <- data_long %>%
                         wilcox_test(
                           Score ~ group,
                           p.adjust.method = "bonferroni"
                         )
                       
                       # 绘图：
                       colors <- c('#eb4b3a', "#48bad0", "#1a9781",
                                            "#355783", "#ef9a80")
                                            p <- ggplot(data_long)+
                                              # 箱线图：
                                              geom_boxplot(aes(group, Score, color = group))+
                                              # 抖动散点：
                                              geom_jitter(aes(group, Score, color = group), width = 0.01)+
                                              # 颜色模式：
                                              scale_color_manual(values = c('#eb4b3a', "#48bad0", "#1a9781",
                                                                                     "#355783", "#ef9a80"))+
                                                                                       xlab("")+
                                              # 主题：
                                              theme_classic()+
                                              theme(legend.position = "none",
                                                    # x轴字体、颜色、角度调整：
                                                    axis.text.x = element_text(angle = 90, vjust = 0.5, face = "bold",
                                                                               color = colors))
                                            
                                            # 根据显著性检验结果，添加显著性标记：
                                            x_value <- rep(1:4, 4:1)
                                            y_value <- rep(apply(data, 2, max)[1:4], 4:1) + 0.01
                                            y_value <- y_value + c(0.03*1:4, 0.03*1:3, 0.03*1:2, 0.03)
                                            color_value <- c(colors[2:5], colors[3:5], colors[4:5], colors[5])
                                            
                                            for (i in 1:nrow(stat.test)) {
                                              if (stat.test$p.adj.signif[i] != "ns") {
                                                y_tmp <- y_value[i]
                                                p <- p+annotate(geom = "text",
                                                                label = stat.test$p.adj.signif[i],
                                                                x = x_value[i],
                                                                y = y_tmp,
                                                                color = color_value[i])
                                              }
                                            }
                                            p_list[[j]] <- p
                     }
                     
library(cowplot)
                     
plot_grid(plotlist = p_list, ncol = 3)
ggsave("all_plot.pdf", height = 5.5, width = 9)



# 构建数据
library(ggplot2)
library(ggsignif)
WT = rnorm(5346,9,1)  
Gain = rnorm(877,10,1)
LOH = rnorm(2619,9,1)
HD = rnorm(774,5,2)


data <- data.frame( #报错了,参数值意味着不同的行数
  WT = rnorm(5346,9,1)  ,
  Gain = rnorm(877,10,1),
  LOH = rnorm(2619,9,1),
  HD = rnorm(774,5,2)
)

# data <- data.frame(
#   WT = rnorm(5,9,1)  ,
#   Gain = rnorm(5,10,1),
#   LOH = rnorm(5,9,1),
#   HD = rnorm(5,5,2)
# )

#         WT      Gain      LOH       HD
# 1 10.961956  8.984755 8.926903 4.792924
# 2  9.371206 10.516329 9.196456 4.761619
# 3  7.706994 10.743725 9.528169 5.403569
# 4  9.980682 10.877571 8.756910 3.550473
# 5  9.332851 11.597205 7.510419 4.900524

# 数据合并
data <- as.data.frame(cbind(rep(c('wt','gain','loh','hd'),c(5346,877,2619,774)),
                           c(WT,Gain,LOH,HD)))
colnames(data) <- c('Group','values')
data$values <- as.numeric(data$values)
data$Group <- factor(data$Group,levels = c('wt','gain','loh','hd')) 
# 生成因子变量，并指定排序

ggplot(data)+
  geom_violin(aes(Group,values))
                     
                     
data1 <- data.frame(
  WT = rnorm(4,9,1)  ,
  Gain = rnorm(4,10,1),
  LOH = rnorm(4,9,1),
  HD = rnorm(4,5,2)
)

data1_ <- pivot_longer(data1, cols = everything(),
             names_to = 'groups',values_to = 'values')
ggplot(data1_)+
  geom_violin(aes(groups,values)) 
#考虑样本的个数，Y的个数
#一个指标在不同组的分布

ggplot(data1_)+
  geom_boxplot(aes(groups,values))+
  geom_point(aes(groups,values))


# select statistical method
# 0: t test
# 1: Wilcoxon rank test
if (statisticalMethod == 0){ 
  `P-VALUE` <- sapply(
    1:ncol(df.a), function(k) {
      # 先检验方差齐性，再计算p-value
      #
      col.a <- df.a[, k]
      col.b <- df.b[, k]
      var <- var.test(col.a, col.b)$p.value > 0.05
      # f检验，方差齐性
      p <- t.test(col.a, col.b, var.equal = var)$p.value  # t检验
    }
  )
} else if (statisticalMethod == 1){
  `P-VALUE` <- sapply(
    1:ncol(df.a), function(k) {
      col.a <- df.a[, k]
      col.b <- df.b[, k]
      p <- wilcox.test(col.a, col.b)$p.value  # 秩和检验
    }
  )
}
if(l.a$p_calculate == 1){
  q <- fdrtool(  # {fdrtool}
    `P-VALUE`, statistic = 'pvalue', plot = F, verbose = F
  )$qval
}else if(l.a$p_calculate == 0){
  q <- p.adjust(`P-VALUE`, method = "fdr", n = length(`P-VALUE`))
}


# 配对t检验和独立样本t检验
