### 数据库
1. 创建库
2. 删除库
### 数据表
1. 创建
2. 删除
3. 查询
   * 查询列
   * 查询行

[sql顺序](https://zhuanlan.zhihu.com/p/531723523)
```sql
-- 大写字母表示表，小写字母表示列
-- 查询多列(逗号隔开)
select a,b,c from A;

-- 去重（去重的行）
select distinct university from user_profile;

-- 限制个数
select device_id from user_profile limit 2;

-- 改列名（显示会改）
select device_id as user_infos_example from user_profile limit 2;

-- 查找学校是北大的学生信息
select device_id ,university from user_profile where university = '北京大学';
select device_id ,university from user_profile where university like '北京%%'; -- 信息表简单，也可以查询到
select device_id ,university from user_profile where university like '北京'; -- 报错

-- 查找年龄大于24岁的用户信息
select device_id, gender, age, university from user_profile where age > 24;

-- 查找某个年龄段的用户信息
select device_id, gender, age from user_profile where age >= 20 and age <= 23;
select device_id, gender, age from user_profile where age between 20 and 23; 

-- 查找除复旦大学的用户信息
-- 实际工作中建议补充university is not null或者使用nvl函数，不然空值会影响分析结果
select device_id,gender,age,university
from user_profile
# where university != '复旦大学'
# where university not like '复旦大学'
# where university not in ('复旦大学')

-- 用where过滤空值练习
select device_id, gender, age, university from user_profile where age is not null;

-- 现在运营想要找到男性且GPA在3.5以上(不包括3.5)的用户进行调研 
select device_id, gender, age, university, gpa from user_profile 
where gpa > 3.5 and gender = 'male';

-- 现在运营想要找到北京大学且GPA在3.7以上(不包括3.7)的用户进行调研
select device_id, gender, age, university, gpa from user_profile 
where university = '北京大学' or gpa > 3.7; --暂不考虑索引

-- 现在运营想要找到学校为北大、复旦和山大的同学进行调研
select device_id, gender, age, university, gpa from user_profile 
where university in ('北京大学','复旦大学','山东大学');


-- 查找GPA最高值
SELECT gpa from user_profile
where university like '复旦%'
order by gpa desc
limit 1;

-- 计算用户的平均次日留存率
SELECT
    COUNT(distinct q2.device_id, q2.date) / count(DISTINCT q1.device_id, q1.date) as avg_ret
from
    question_practice_detail as q1
    left outer join question_practice_detail as q2 on q1.device_id = q2.device_id
    and DATEDIFF (q2.date, q1.date) = 1


```

## 注意
1. 别名很有用！！（多表连接时）