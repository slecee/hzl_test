library(readr)
library(tidyverse) 
library(openxlsx) # 主要是写入漂亮的excel格式 （https://zhuanlan.zhihu.com/p/349529408）
library(readxl) # excel_sheets函数主要是读 

# 数据读取----------------------
# ?read_csv()
# csv 一些重要的参数 col_names 默认为T， skip = ，skip_empty_rows = TRUE
# ?read.xlsx()
# xlsx 重要的参数 第几个表sheet = (这也是循环的关键)，colNames = TRUE，rowNames = FALSE,
# 在openxlsx没有可以读取表名的函数
# 可以readxl(excel_sheets函数)

# wb <- loadWorkbook(system.file("extdata", "readTest.xlsx", package = "openxlsx"))

csv <- read_csv() # tibble
xlsx <- read.xlsx() # 

# readxl
# read_excel	        Read xls and xlsx files.
# read_xlsx	        Read xls and xlsx files.
# 
# excel_sheets	         List all sheets in an excel spreadsheet.
# readxl_example	        Get path to readxl example
# 
# anchored	        Specify cells for reading
# cell-specification	Specify cells for reading
# cell_cols	        Specify cells for reading
# cell_limits	        Specify cells for reading
# cell_rows	        Specify cells for reading


# 数据导出-------------
# Ps:当数据量较大时，目前采用writexl::write_xlsx(dt,'test.xlsx')输出Excel文件，
# 这是我知道的现阶段输出Excel格式速度最快的包。
# 该包的函数很简单，主要就是write_xlsx()功能。