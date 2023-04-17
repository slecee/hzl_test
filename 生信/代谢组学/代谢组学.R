setwd("D:\\project\\shengxin\\CAA")
library(readxl)
library(pmp)
library(ggplot2)
library(ggrepel)
library(openxlsx)
library(tidyverse)
library(ropls)
library(ggrepel)
library(fdrtool)
library(plotly)



data <- read.xlsx("neg.xlsx")
# hmdb <- read_csv('NEG-CAA-identified-HMDB.csv',col_names = T)
# 这里第一行是空行
data1 <- data[!is.na(data$HMDB),]

# 有重名的应该怎么删除呢？峰面积最大还是？
# unique(data1$desc)
data2 <- data1[!duplicated(data1$DESC),]
rownames(data2) <- data2$DESC


# 整理数据---------

# 数据目前是两个sheet表（自己的流程会是3个），一个是定量的表（主要是峰面积），
# 一个是定性的表（含物质名称，HMDB等等），一般是通过Compound进行合并连接。
# 目前的问题是没有二级碎片库，在一级上有很多种可能，所以会匹配特别多

# 1.因为给的数据这里包含两个数据库，暂时只要HMDB这个库，
# 区别在Compound ID中HMDB库以HMDB开头

# hmdb1 <- hmdb %>% #选出所有列范围内，存在值包含 “HMDB” 的行
#   filter(if_any(everything(), ~ str_detect(.x, "HMDB")))

# 正则表达式 hmdb2、hmdb3和hmdb4是一样的
# grepl返回的是逻辑向量
hmdb2 <- hmdb %>% #选出`Compound ID`列，存在值包含 “HMDB” 的行
    filter(if_any(`Compound ID`, ~ str_detect(.x, "HMDB")))

hmdb3 <- hmdb[grepl("^HMDB",hmdb$`Compound ID`),]

hmdb4 <- hmdb[str_detect(hmdb$`Compound ID`, "HMDB"),]


# 2.左连接
# 左连接，问题在没办法唯一确定，因为每个物质都有很多种可能，现在没有二级
# 目前可以用excel，会自动选择第一个
aaaa <- data %>% 
  left_join(hmdb2,by = 'Compound') 


# 这里是excel处理过后，库包含物质量的问题，会导致部分峰面积匹配不到，
# 显示为HMDB（compound id）这一列为空，现在将其删除
data1 <- data[!is.na(data$HMDB),]

# 3.数据整理
# 把QC放在最后，desc作为列名
# 此外数据可能因检测不到或其他原因检测不到，应该设为NA，这里是为0
if (0){
  data <- data %>% 
    select(everything(),-contains('QC'),contains('QC'))
}
# rownames(data) <- data$desc
data2[data2 == 0] <- NA # data是个矩阵，data==0返回的是一个真假值矩阵

# 4.样本信息
# 每次的分组样本量都是不同的，所以后面不能写死
# 把数据分成3部分，前面的描述性信息，中间的样本数据，后面是qc样本
group = c(4,4)
sample = c('caa','dz')
qc = 0 # 现在没qc
des = 5  # 现在前面有5列


# group_yuan = '4 4'
# group_yuan = str_split(group_yuan, pattern = ' ') %>% 
#   unlist() %>% 
#   as.numeric()

# 5.数据判断---------------
# 最好是qc的RSD进行判断，现在没有
# 四分位也能用吧（删除明显的异常值，注意如果qc，是不包含qc列的）
# data_sfw是仅含数据的列
if (qc == 0){
  data3 <- data2 %>% 
  select(contains(c('CAA','DZ')))
  data_sfw <- apply(data3, 1,function(row) { 
    quan <- quantile(row, probs = c(0.25,0.75), na.rm = T)
  # xia <- quantile(row[row != 0],0.25)
  # shang <- quantile(row[row != 0],0.75)
    row_max <- quan[[2]] + 1.5 * (quan[[2]] - quan[[1]]) # 常用为1.5,更宽松一点可以设为3
    row_min <- quan[[1]] - 1.5 * (quan[[2]] - quan[[1]])
    row[row < row_min] <- NA #
    row[row > row_max] <- NA # 
    return(row)
    }) %>% 
      t() %>%
      as.data.frame()
}else{
  
}
# data_sfw <- t(data_sfw) %>% 
#   as.data.frame()

# 6.数据过滤
# 有qc，qc含量低于50%直接删除
# 没有qc，每一个代谢物的NA值超过50%删除该物质
if (qc != 0){
  zhanbi = rowSums(is.na(data[,(des+sum(group))+1:ncol(data)]))/qc # 返回的是真假值数组
  data <- data[c(zhanbi<0.5),]%>%
    as.data.frame()
}
# [,1:(des+sum(group))]
zhanbi_data = rowSums(is.na(data_sfw))/sum(group)
data_sfw_filter <- data_sfw[c(zhanbi_data<0.5),]%>%
  as.data.frame()

# 过滤 要改成apply
#  zhanbi_1 <- data[,(des+1):(des+group[1])] %>%
#     is.na() %>%
#     rowSums()/group[1]
# 
#  # zhanbi_2 <- rowSums(is.na(data[,8:11]))/4
#  zhanbi_2 <- data[,(des+group[1]+1):(des+sum(group))] %>%
#    is.na() %>%
#    rowSums()/group[[2]]
# 
# data_filter_1 <- data[c((zhanbi_1 < 0.5)&(zhanbi_2 <0.5)),]%>%
#   as.data.frame()


# 7.数据填补-------------


# 1. 全部填补最小值的1/2 （感觉跟0没区别）


min_num = min(apply(data_sfw_filter[,4:11], MARGIN = 1, min, na.rm = T))
# MIN_<- apply(data_filter_1[,4:11],1,min,na.rm = T) %>% 
 #  min()
data[is.na(data)] <- min_num/2
data_sfw_filter_tianbu = cbind(data_sfw_filter[,1:3],copy_data_sfw_filter)

# 2.metaboan 填补检测出每个代谢物含量的最小值的1/5

data_sfw_tianbu <- apply(data_sfw_filter,1, function(row) {
  # 填充最小值的二分之一
  row[is.na(row)] <- min(row,na.rm = T)/5
  return(row)
}) %>% 
  t() %>%  
  as.data.frame()


# 8.数据归一化
# 8.1 面积归一化
data_sfw_guiyi <- sapply(data_sfw_tianbu, function(column) {
  # 利用面积矫正
  #
  sum.col <- sum(column)
  column <- column / sum.col
})%>% as.data.frame()
 
rownames(data_sfw_guiyi) <- rownames(data_sfw_tianbu)
# 一样的
# data_mianji = apply(as.data.frame(data_sfw_filter_tianbu[,4:11]), 2,function(df_column){
#   # 利用面积矫正
#   #
#   sum_col <- sum(df_column)
#   df_column <- df_column / sum_col
# }) %>% as.data.frame()

# 8.2 内标归一化


# 9.统计学检验
# t检验 前提是数据的正态分布，这里取了log
# 秩和检验
# fdr
# anova

group_mark <- rep(c("CAA","DZ"),each = 4)


p <- apply(log2(data_sfw_guiyi+ 1),1, function(x) {
  var <- var.test(x[1:group[1]],x[(group[1]+1):sum(group)])$p.value > 0.05 # x[1:4],x[5:8]
  t.test(x~group_mark, var.equal = var)$p.value  
  # t.test(x[1:4],x[5:8])$p.value 相等 x是数值变量，~后面跟分类变量
  # var.equal T就是t检验 F就是秩和检验
})


fdr <- p.adjust(p ,method = 'fdr') #计算方式挺有意思的-_-
# length(fdr[fdr<0.05])
# q <- fdrtool::fdrtool(  # {fdrtool}
#  p, statistic = 'pvalue', plot = F, verbose = F
# )$qval

# mean <- apply(data_mianji_he[,4:11],1, function(x) {
#   c(sum(x[1:4])/group_yuan[1],sum(x[5:8])/group_yuan[2])
# })
# # mean<-2^mean-1
# mean[1,]/mean[2,]->FC

mean <- apply(data_sfw_guiyi,1, function(x) {
  c(sum(x[1:group[1]])/group[1],sum(x[group[1]:ncol(data_sfw_guiyi)])/group[2])
})

FC <- mean[1,]/mean[2,]
logfc <- log2(FC)

# data_output <- cbind(data_sfw_filter[,1:3],data,p,fdr,FC,logfc)

#还差个vip

# write.xlsx(data_output,'D:/project/shengxin/CAA/output.xlsx')


# 10.pca与opls-da
# 数据需要是样本是行，代谢物是列，一般需要转置
# pca@modelDF[["R2X"]] 这个是主成分得分数
# pca@scoreMN[,c('p1','p2')]坐标

pca <- opls(x = t(data_sfw_guiyi),
                 log10L = T, scaleC = 'standard',
                 crossvalI = 7 
)
if(data_pca@summaryDF$pre < 3) {  # 主成分不少于3，方便做三维图
  pca <- opls(
    x = t(data_sfw_guiyi), predI = 3, 
    log10L = T, scaleC = 'standard', 
    crossvalI = 7,
    
  )}

xlab1 <- paste0("PC1(",round(pca@modelDF[["R2X"]][1]*100,2),"%)")
ylab1 <- paste0("PC2(",round(pca@modelDF[["R2X"]][2]*100,2),"%)")

group = rep(c('CAA','DZ'),each = 4)
data_pca_picture <- as.data.frame(pca@scoreMN[,c('p1','p2')])
# data_pca_picture_1 <- as.data.frame(cbind(data_pca_picture,group))

# pca@scoreMN[,c('p1','p2','p3')]

# pca@loadingMN[,c('p1','p2')] 
# pca@loadingMN[,c('p1','p2','p3')]

# 改格式，改坐标轴刻度，更好看一点

pca_picture <- ggplot(data = data_pca_picture ,aes(x = p1,y = p2,color = group))+
  geom_point(size = 3)+
  # theme(axis.text.y = element_blank(),
  #       axis.text.x = element_blank())+
  labs(x = xlab1,y = ylab1,title = "Plot of PCA score")+
  theme_bw()+
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank())+
  # stat_ellipse(
  #   geom = "polygon", alpha = 0.1, level = 0.95, show.legend = F,
  #   col="black",size=1,type = 't' #  a multivariate t-distribution
  # )
  stat_ellipse(
    geom = "polygon", alpha = 0.1, level = 0.95, show.legend = F,
    col="black",linewidth=1,type = 'norm' # a multivariate normal distribution
    )+
  geom_label_repel(
    # data = df.p1, 
    data = data_pca_picture, 
    mapping = aes(p1, p2, label = rownames(data_pca_picture)), 
    color = 'black', size = 3, 
    label.padding = unit(0.2, 'lines'), 
    point.padding = unit(0.5, 'lines'), 
    min.segment.length = unit(0.1, "lines"), 
    segment.color = 'grey50', segment.size = 1, 
    show.legend = F
  ) 

ggsave(
  paste0(getwd(), '/pca.pdf'), pca_picture, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)
ggsave(
  paste0(getwd(), '/pca.png'), pca_picture, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)


pca_plotly <- ggplotly(pca_picture)
htmlwidgets::saveWidget(pca_plotly, file = "pca.html")

  # theme(
  #   legend.title = element_blank(), 
  #   legend.key = element_blank(),
  #   panel.grid.major = element_blank(), 
  #   panel.grid.minor = element_blank(), 
  #   legend.text = element_text(size = 10, color = "black",family = "sans",
  #                              face = "plain", vjust = 0.5, hjust = 0),
  #   # legend.title = element_text(size = 16, color = "black",family = "sans",
  #   #                             face = "plain", vjust = 0.5, hjust = 0),
  #   legend.key.size = unit(0.8,"cm"),
  #   axis.text = element_text(size = 10, color = "black",family = "sans",
  #                            face = "plain", vjust = 0.5, hjust = 0.5),  ###  控制坐标轴刻度的大小颜色
  #   axis.title = element_text(size = 10, color = "black", family = "sans",
  #                             face = "plain", vjust = 0.5, hjust = 0.5) ###  控制坐标轴标题的大小颜色
  # )
  # stat_ellipse(
  #   data = data_pca_picture_1, geom = 'polygon', level = 0.95, 
  #   aes(p1, p2, color =  group), alpha = 0.1
  # ) 
  # stat_ellipse( geom = "polygon", alpha = 0.1, level = 0.95, show.legend = F,
  #               col="black",linewidth=1)


data_opls_da <- opls(x = t(data_sfw_guiyi), y = group,
                 log10L = T, scaleC = 'standard',
                 crossvalI = 7 ,predI = 1, ortho = 1, permI = 200, 
)

VIP <- data_opls_da@vipVn

to1 <- data_opls_da@orthoScoreMN
t1 <- data_opls_da@scoreMN 
data_opls <- as.data.frame(cbind(t1 ,to1))
colnames(data_opls) <- c('t1','to1')
  
xlab2 <- paste0("t1(",round(data_opls_da@modelDF[["R2X"]][1]*100,2),"%)")
ylab2 <- paste0("to1(",round(data_opls_da@modelDF[["R2X"]][2]*100,2),"%)")

opls_da_pic <- ggplot(data = data_opls ,aes(x = t1,y = to1,color = group))+
  geom_point(size = 3)+
  # theme(axis.text.y = element_blank(),
  #       axis.text.x = element_blank())+
  labs(x = xlab2,y = ylab2,title = "Plot of OPLS-DA")+
  theme_bw()+
  theme(
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  )+
  stat_ellipse(
    geom = "polygon", alpha = 0.1, level = 0.95, show.legend = F,
    col="black",size=1,type = 'norm' # a multivariate normal distribution
  )+
  geom_label_repel(
    # data = df.p1, 
    data = data_opls , 
    mapping = aes(t1, to1, label = rownames(data_opls )), 
    color = 'black', size = 3, 
    label.padding = unit(0.2, 'lines'), 
    point.padding = unit(0.5, 'lines'), 
    min.segment.length = unit(0.1, "lines"), 
    segment.color = 'grey50', segment.size = 1, 
    show.legend = F
  )

ggsave(
  paste0(getwd(), '/neg_opls-da.pdf'), opls_da_pic, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)
ggsave(
  paste0(getwd(), '/neg_opls-da.png'), opls_da_pic, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)


ggplotly(p.pca2)
htmlwidgets::saveWidget(p.pca2, file = "pca.html")


# ggplot(j, aes(p1, o1,group = group,col=group)) + #映射PC1,PC2
#   geom_point(size = 7) + #绘制得分散点图
#   labs(title = "PCA - biplot") + #图表标题
#   xlab(paste("to1")) + #x轴标题
#   ylab(paste("t1")) + #y轴标题
#   stat_ellipse( geom = "polygon", alpha = 0.1, level = 0.95, show.legend = F,
#                 size=1)+#加置信椭圆
#   geom_vline(xintercept=mean(j$p1),lty=1,col="black",lwd=0.5) +#添加横线
#   geom_hline(yintercept =mean(j$o1),lty=1,col="black",lwd=0.5)+#添加竖线
#   theme( plot.background = element_rect(fill="white"),
#          panel.background = element_rect(fill='white', colour='gray'),          
#          strip.text.x=element_text(size=rel(1.2), family="serif", angle=-90),
#          strip.text.y=element_text(size=rel(1.2),  family="serif") ,
#          axis.text.x = element_text(size = 14,color="black"),
#          axis.text.y = element_text(size = 20,color="black"),axis.ticks.x=element_blank()
#   )+
#   geom_text_repel(data = j ,
#                   aes(label = name),
#                   size = 7,
#                   colour = "red",
#                   box.padding = unit(0.2, "lines"),
#                   point.padding = unit(0.1, "lines"), segment.color = "black", show.legend = FALSE )
# 


data_bind <- cbind(data_sfw_guiyi,p,fdr,FC,logfc,VIP)
data_chayi <- data_bind[(data_bind$p < 0.05)& (data_bind$VIP > 1),]

write.xlsx(data_chayi,file = "D:/project/shengxin/CAA/data_chayi.xlsx",
           rowNames = T)


# 11.火山图--------------------

sum((data_bind$p < 0.05) & (data_bind$VIP > 1))


data_bind$deg <- 'not significant' # 增加一列
data_bind$deg[(data_bind$p < 0.05) & (data_bind$VIP > 1)& (data_bind$FC < 1)]<-'down-regulated'
data_bind$deg[(data_bind$p < 0.05) & (data_bind$VIP > 1)& (data_bind$FC > 1)]<-'up-regulated'
sum(data_bind$deg =='up-regulated' ) 
sum(data_bind$deg =='down-regulated' ) 
sum(data_bind$deg =='not significant' ) 
volcano <- ggplot() +
  geom_blank(data = data_bind, aes(logfc, -log10(p), size = VIP)) +
  geom_hline(
    yintercept = c(-log10(0.05)), 
    color = 'grey50', linetype = 'dashed'
  ) +
  geom_vline(xintercept = 0 , # c(log2(0.5), log2(2)), 
             color = 'grey50', linetype = 'dashed') +
  geom_point(
    data = data_bind[data_bind$deg == "not significant", ], 
    aes(logfc, -log10(p), size = VIP, color = deg),
  ) +
  geom_point(
    data = data_bind[data_bind$deg != "not significant", ], 
    aes(logfc, -log10(p), size = VIP, color = deg)
  ) +
  scale_color_manual(
    name = 'Status', values = c(
      'down-regulated' = '#619cffa0', 'not significant' = '#b3b3b350', 
      'up-regulated' = '#f8766da0'
    ), guide = guide_legend(order = 1, override.aes = list(size = 2))
  ) +
  scale_size_continuous(
    name = 'VIP', guide = guide_legend(order = 2), range = c(2, 4), 
    breaks = c(min(data_bind$VIP), max(data_bind$VIP)), 
    labels = c('0.0', round(max(data_bind$VIP), 1))
  ) +
  theme_bw() +
  theme(
    legend.key = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.border = element_rect(color = 'black', size = 1),
    # ggplot作图时均可使用如下参数
    legend.text = element_text(size = 20, color = "black",family = "sans",
                               face = "plain", vjust = 0.5, hjust = 0),  ###  控制图例标签的字体大小颜色
    ### 字体：sans=Arial   serif=Times New Roman  mono=Courier New
    legend.title = element_text(size = 20, color = "black",family = "sans",
                                face = "plain", vjust = 0.5, hjust = 0), ###  控制图例标题的字体大小颜色
    legend.key.size = unit(0.3,"cm"),  ###   控制图例图标的尺寸
    axis.text = element_text(size = 20, color = "black",family = "sans",
                             face = "plain", vjust = 0.5, hjust = 0.5),  ###  控制坐标轴刻度的字体大小颜色
    axis.title = element_text(size = 20, color = "black", family = "sans",
                              face = "plain", vjust = 0.5, hjust = 0.5) ###  控制坐标轴标题的字体大小颜色
  ) +
  labs(
    x = expression(paste(log[2], ' Fold Change')), 
    # y = expression(paste(-log[10], ' ', italic('P'), '-value'))
    y = expression(paste(-log[10], ' ', 'P-value'))
  )
ggsave(
  paste0(getwd(), '/volcano plot.jpg'), volcano, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)
ggsave(
  paste0(getwd(), '/volcano plot.pdf'), volcano, 
  width = 12, height = 7.5, units = 'in', dpi = 600
)



# ggplot(data_chayi,aes(x = logfc,y = -log10(fdr)))+
#   geom_hline( # 画水平的虚线，为了防止遮住点，放在这里 图层的应用
#     yintercept = c(-log10(0.05)), 
#     color = 'grey50', linetype = 'dashed'# 在哪画颜色是啥形状是啥，
#   ) +
#   geom_vline(xintercept = c(log2(0.5), log2(2)), 
#              color = 'grey50', linetype = 'dashed') +
#   geom_point(
#     aes(size = -log10(p) ,color = -log10(p)) #颜色与大小的渐变
#     
#   )+
#   scale_size_continuous(range = c(1,3))+ #我们的变量是连续型变量 
#   scale_color_gradientn(
#     values = seq(0,1,0.2), #分几段，6个数5个间隔
#     colors = c('#39789f','#39bbec','#f9ed36','#f38466','#b81f25')
#     
#   )+
  # scale_color_gradient2(low = 'blue', mid = 'white', high ='red' ,
  #                        midpoint = 2) +
# scale_color_gradient 设置颜色（设置两个） 2设置3个 n设置多个
# mid_point默认是0，需要改一下
  # theme_bw()+ #四周的边框
  # theme(                 # ?theme
  #   panel.grid = element_blank(),#去掉内部的线
  #   # legend.position = c(0.01,0.7),# 改图例的位置，自己调一下
  #   # legend.justification = c(0,1) # 将默认初始位置改为0，1，这俩连用的
  # )+
  # guides(col = guide_colorbar(title = '12'),#改连续型的图例名称
  #        size = 'none',#
  #        # size = 'none' 不要了，col可以改，正则吗？
  #        # 改成col11，size12是没改名称的，应该是和ggpoint的aes对应的
  #        )+
  # #geom_text()+ #加文字，主要是过滤数据后
  # geom_text_repel()+#ggrepel的包，更美观一点+
  # labs(x = '',y = '',title = '',)



# 12.热图
library(pheatmap)
# library(ComplexHeatmap)
# data_chayi_shang <- data_bind[(data_bind$fdr < 0.05)& (data_bind$VIP > 1)&(data_bind$logfc > 2),]
# data_chayi_xia <- data_bind[(data_bind$fdr < 0.05)& (data_bind$VIP > 1)&(data_bind$logfc < 0.5),]
# data_chayi <- rbind(data_chayi_shang,data_chayi_xia)

data_chayi <- data_bind[(data_bind$p < 0.05)& (data_bind$VIP > 1),]
data_heatmap <- data_chayi[,1:8]




# label.col <-c(rep('NC',7),rep('CP',7),rep('A',7))
# label.col <- c(rep(c('D_','H_'),c(83,84)))
label.col <- c(paste0('CAA',seq(1,4)),paste0('DZ',seq(1,4)))
label.col <- c(rep(c( "CAA","DZ"), c(4,4)))

annotation_col <-  data.frame(
  Group = factor(c(rep(c( "CAA","DZ"), c(4,4))))
)
rownames(annotation_col) = colnames(data_heatmap) 
# 不能少这一句，要让annotation_col的行名等于data_heatmap的列名

ann_color = list(Group=c("CAA" = '#00CDCD', "DZ" = '#CD2626'))
# 这一行影响不大，要测试一下
# rownames(annotation_col) = colnames(df.data[,-1])
# pdf() dev.off()矢量图
pheatmap::pheatmap(
  data_heatmap, 
  color = colorRampPalette(c("blue", "white", "red"))(50),#色块渐变情况
  show_rownames = F,show_colnames = T,
  scale = 'row',   # 按行标准化,
  cellwidth = 20, cellheight = 6,border_color = NA,
  cluster_cols = F, cluster_rows = T, # 行聚类列不聚类
  fontsize = 15,
  height = NA,
  annotation_col = annotation_col,
  filename ="D:/project/shengxin/CAA/heatmap.pdf")
 


# 13.相关热图
library(corrplot)
library(ggcorrplot)


data_corr <- t(data_heatmap)
M_ <- cor(data_corr)
p_mat <- cor.mtest(data_corr,conf.level = 0.95)

# p_mat <- cor_pmat(data_corr) ggcorrplot
# 图层的嵌套
pdf(
  "D:/project/shengxin/CAA/corr.pdf",
  width = 30, height = 15
)
corrplot::corrplot(M_,# 相关性矩阵
                   p.mat = p_mat$p ,# 相关性矩阵的p值
                   method = 'color', # 默认是圆圈，现在是颜色块
                   sig.level = c(0.001,0.01,0.05), #  0.05到0.01一颗星，以此类推
                   pch.cex = 0.9,#标记大小，注意现在是不显著的打X
                   insig = 'label_sig', # 现在是星号
                   pch.col = 'gray', # 标记颜色
                   order = 'AOE', #聚类方法
                   tl.col = 'black', # 坐标轴字体颜色
                   tl.pos = 'tp', # 名称全是这部分出的
                   type = 'upper',#上半部分
                   tl.cex = 0.1
                   
                   
)
# corrplot::corrplot(M_,# 相关性矩阵
#                    p.mat = p_mat$p ,# 相关性矩阵的p值
#                    method = 'number', # 默认是圆圈，现在是颜色块
#                    add = TRUE ,#上下联用
#                    insig = 'blank', # 不加不显著的是X，加了为空白
#                    number.cex = 0.8, # 标记颜色
#                    order = 'AOE', #聚类方法
#                    tl.col = 'black', # 坐标轴字体颜色
#                    type = 'lower',#下半部分
#                    tl.pos = 'n', #不要了
#                    # tl.pos = 'd', # 对角线显示的名称
#                    cl.pos = 'n' ,# 图例，下半部分的图例不要了
#                    
# )
dev.off()

# 相关性热图测试,注意数据结构
data('mtcars')
mt <- mtcars
M <- cor(mtcars) # ?cor method：相关性系数计算方法(pearson/kendall/spearman)
testP <- cor_pmat(mtcars) # 计算p值

# 图层的嵌套
corrplot::corrplot(M,# 相关性矩阵
                   p.mat = testP ,# 相关性矩阵的p值
                   method = 'color', # 默认是圆圈，现在是颜色块
                   sig.level = c(0.001,0.01,0.05), #  0.05到0.01一颗星，以此类推
                   pch.cex = 0.9,#标记大小，注意现在是不显著的打X
                   insig = 'label_sig', # 现在是星号
                   pch.col = 'gray', # 标记颜色
                   order = 'AOE', #聚类方法
                   tl.col = 'black', # 坐标轴字体颜色
                   tl.pos = 'tp', # 名称全是这部分出的
                   type = 'upper',#上半部分
                   
                   )
corrplot::corrplot(M,# 相关性矩阵
                   p.mat = testP ,# 相关性矩阵的p值
                   method = 'number', # 默认是圆圈，现在是颜色块
                   add = TRUE ,#上下联用
                   insig = 'blank', # 不加不显著的是X，加了为空白
                   number.cex = 0.8, # 标记颜色
                   order = 'AOE', #聚类方法
                   tl.col = 'black', # 坐标轴字体颜色
                   type = 'lower',#下半部分
                   tl.pos = 'n', #不要了
                   # tl.pos = 'd', # 对角线显示的名称
                   cl.pos = 'n' # 图例，下半部分的图例不要了
)

# ggcorrplot(corr = M, # 相关性矩阵
#            p.mat = testP , # 相关性矩阵的p值
#            sig.level = c(0.001,0.01,0.05), # 0.05到0.01一颗星，以此类推
#            insig = "blank" ,# 隐藏p>0.05的样本(设置为pch则不显著的画×)
#            method = "square", # square(矩形)/circle(环形)
#            hc.order = TRUE, # 使用聚类顺序
#            hc.method = "complete", # 聚类算法
#            outline.color = "white", # 矩形边框颜色
#            ggtheme = theme_bw(), # ggplot2函数的绘图主题
#            type = "lower", # 只绘制相关性下部分
#            show.diag = TRUE,# 显示对角线关系
#            colors = c("#6D9EC1", "white", "#E46726"), # 填充颜色
#           
#          
# )

p.cor <- ggcorrplot(corr = cor_data, # 相关性矩阵
                    method = "square", # square(矩形)/circle(环形)
                    hc.order = TRUE, # 使用聚类顺序
                    hc.method = "complete", # 聚类算法
                    outline.color = "white", # 矩形边框颜色
                    ggtheme = theme_bw(), # ggplot2函数的绘图主题
                    type = "lower", # 只绘制相关性下部分
                    show.diag = TRUE,# 显示对角线关系
                    colors = c("#6D9EC1", "white", "#E46726"), # 填充颜色
                    p.mat = p_mat, # 相关性矩阵的p值
                    insig = "blank" # 隐藏p>0.05的样本(设置为pch则不显著的画×)
)





# 14.箱型图



# 15.venn图


# 16


# 1*.代谢通路图---------
path<-"D:/project/shengxin/CAA/caa-neg"
setwd(path)
library(openxlsx)
library(ggplot2)
library(treemap)
#library(xlsx)
# files<-list.files(path)
# files<-grep("2-1pathway-analysis.xlsx", files, ignore.case = TRUE, value = TRUE)
# # for(i in 1:3){
# #   pol<-strsplit(files[i],".xlsx")[[1]]
# #   subdir<-paste0(path,"/",pol)
# #   if (!dir.exists(subdir)){
# #     dir.create(subdir)
# #   }
#   df.ma <- read.xlsx(files[i],sheet=1 )
df.ma<-read.xlsx("NEG-Pathway Analysis.xlsx",sheet=1,colNames=T,rowNames=F)
#df.ma<-read.csv("pathway_results.csv")
colnames(df.ma)<-c("pathway","Total","Hits","Raw.p","p","Holm.adjust","FDR","impact")
#colnames(df.ma)<-c("pathway","Total","Hits","Raw.p","p","Holm.adjust","FDR","impact")

df.ma$impact.mod <- df.ma$impact + 0.001

# 树图跟气泡图一样的，可以稍微好看点
jpeg(
  filename = paste0(
    'pos', '-treemap.jpg'
  )
  , res = 600, width = 6000, height = 6000
)
treemap::treemap(
  df.ma, index = 'pathway', vSize = 'impact.mod', 
  vColor = 'p', title = '', 
  title.legend = expression(
    paste(-ln, ' ', italic('P'), '-value')
  ), 
  type = 'value', 
  #palette = '-RdYlBu',
  fontfamily.title="sans",
  fontfamily.labels="sans",
  fontfamily.legend="sans",
  fontsize.legend=14,
  fontsize.labels=14,
  fontsize.title=14,
  #palette='Greens',
  palette = 'Reds', 
  range = c(0, 3), mapping = c(0, 1.5, 3)
)
dev.off()
pdf(
  paste0(
    'pos', '-treemap.pdf'
  )
)
treemap::treemap(
  df.ma, index = 'pathway', vSize = 'impact.mod', 
  vColor = 'p', title = '', 
  title.legend = expression(
    paste(-ln, ' ', italic('P'), '-value')
  ), 
  type = 'value', 
  #palette = '-RdYlBu', 
  fontfamily.title="sans",
  fontfamily.labels="sans",
  fontfamily.legend="sans",
  fontsize.legend=14,
  fontsize.labels=14,
  fontsize.title=14,
  #palette='Greens',
  palette = 'Reds', 
  range = c(0, 3), mapping = c(0, 1.5, 3)
)
dev.off()

DrawBubblePlot <- function(df.ma) {
  require(ggplot2)
  require(ggrepel)
  if(length(which(df.ma$impact > 0)) >= 5) {
    filter <- expression(
      df.ma$impact >= sort(df.ma$impact, decreasing = T)[5]
    )
  } else {
    filter <- expression(df.ma$impact >= 0)
  }
  data = df.ma[eval(filter) | df.ma$Raw.p < 0.05, ]
  #data$label=as.roman(1:10)
  p <- ggplot() +
    geom_point(
      data = df.ma, shape = 21, color = 'black', stroke = 1, 
      mapping = aes(x = impact, y = p, size = impact, fill = p)
    ) +
    geom_label_repel(
      data = df.ma[eval(filter) | df.ma$Raw.p < 0.05, ],
      #data=df.ma,
      mapping = aes(impact, p, fill = p, label = pathway),
      #mapping = aes(impact, p, fill = p, label = data$label),
      color = 'black', size =4.94,
      label.padding = unit(0.2, 'lines'),
      point.padding = unit(0.5, 'lines'),
      min.segment.length = unit(0.1, "lines"),
      segment.color = 'grey50', segment.size = 1,
      show.legend = F
    )+
    theme_bw() +
    theme(
      panel.grid.major = element_line(
        color = '#3f00f6', linetype = 'dashed'
      ), 
      panel.grid.minor = element_blank(),
      legend.text = element_text(size = 10, color = "black",family = "sans",
                                 face = "plain", vjust = 0.5, hjust = 0),
      legend.title = element_text(size = 14, color = "black",family = "sans",
                                  face = "plain", vjust = 0.5, hjust = 0),
      legend.key.size = unit(0.8,"cm"),
      axis.text = element_text(size = 14, color = "black",family = "sans",
                               face = "plain", vjust = 0.5, hjust = 0.5),  ###  控制坐标轴刻度的大小颜色
      axis.title = element_text(size = 14, color = "black", family = "sans",
                                face = "plain", vjust = 0.5, hjust = 0.5) ###  控制坐标轴标题的大小颜色
      
    ) +
    scale_size_continuous(
      name = 'Impact', range = c(8, 16), 
      breaks = c(min(df.ma$impact), max(df.ma$impact)),
      labels = c(min(df.ma$impact), round(max(df.ma$impact), 3)),
      guide = guide_legend(title.hjust = 0.5)
    ) + 
    scale_fill_gradient(
      name = expression(paste(-ln, ' ', italic('P'), '-value')), 
      low = '#86ABED', high = '#FF4040',
      #low='#7EC0EE',high='#4876FF',
      # low = 'white', high = 'red',
      guide = guide_colorbar(
        title.position = 'top', title.hjust = 0.5, 
        direction = 'horizontal'
      )
    ) +
    labs(
      x = 'Impact', 
      y = expression(paste(-ln, ' ', italic('P'), '-value'))
    )
}
if(1) {
  p <- DrawBubblePlot(df.ma)
  ggsave(
    paste0(
      'Bubble Plot.pdf'
    ), p, 
    width = 9.6, height = 7.2, units = 'in', dpi = 600
  )
  ggsave(
    paste0(
      'Bubble Plot.jpg'
    ), p, 
    width = 9.6, height = 7.2, units = 'in', dpi = 600
  )
}

