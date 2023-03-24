# !/usr/bin/env R 
#(linux)

options(stringsAsFactors = F,timeout = 200) #不要把字符串改成因子变量，超时退出
#设置路径-------------------
getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) #设置为当前脚本所在的路径
# print(dirname(rstudioapi::getActiveDocumentContext()$path))

# 标准化输出当前家目录-------------------------------
# paste0(normalizePath('~'),'/a') 
# 
# "C:\\Users\\Lenovo\\Documents" windows
# "/home/rstudio" linux

# 创建文件夹（linux）-------------------
if (!dir.exists(paste0(normalizePath('~'),'/project'))){
  dir.create(paste0(normalizePath('~'),'/project'))
}

sapply(
  c('results', 'others'), function(dir) {
    dir.t <- paste('/home/rstudio/project', dir, sep = '/') 
    
    if(!dir.exists(dir.t)) dir.create(dir.t)
    if (dir == 'results' & !is.na(pol)) {
      dir.p <- paste(dir.t, pol, sep = '/')
      if(!dir.exists(dir.p)) dir.create(dir.p)
    } # 只有result文件夹里需要有POS和NEG
  }
)
map(
  c('results', 'others'), function(dir){
  dir.t <- str_c('/home/rstudio/project', dir, sep = '/')
  if(!dir.exists(dir.t)) dir.create(dir.t)
  if (dir == 'results' & !is.na(pol)) {
  dir.p <- paste(dir.t, pol, sep = '/')
  if(!dir.exists(dir.p)) dir.create(dir.p)
} # 只有result文件夹里需要有POS和NEG
  }
)