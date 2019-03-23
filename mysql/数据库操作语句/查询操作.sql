CREATE TABLE zhangwu(
id INT PRIMARY KEY AUTO_INCREMENT, -- 账务id
zname VARCHAR(200), -- 账务名称
zmoney DOUBLE -- 金额
);
ALTER TABLE zhangwu CHANGE zname zname VARCHAR(200) CHARACTER SET utf8;
INSERT INTO zhangwu(id,zname,zmoney) VALUES (1,'吃饭支出',247);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (2,'工资支出',12354);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (3,'服装支出',1000);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (4,'吃饭支出',235);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (5,'股票收入',247);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (6,'打麻将支出',247);
INSERT INTO zhangwu(id,zname,zmoney) VALUES (7,NULL,538);

/*
查询指定列的数据
格式：
	select 列名1，列名2 from 表名
*/
SELECT * FROM zhangwu;

/*
查询所有列的数据
格式：
	select * from 表名
*/
SELECT * FROM zhangwu;

/*
查询去掉重复记录
	distinct 关键字 跟随列名
*/
SELECT DISTINCT zname FROM zhangwu;

/*
查询重新命名列
as 关键字
*/
SELECT zname AS '名称' FROM zhangwu;

/*
查询数据中，直接进行数学计算
列对数字进行计算
*/
--zmoney+1000进行查看
SELECT zname,zmoney +1000 FROM zhangwu;

-- 查询所有吃饭支出
SELECT * FROM zhangwu WHERE zname = '吃饭支出';

-- 查询金额大于1000
SELECT * FROM zhangwu WHERE zmoney >1000;

-- 查询金额在500到1000之间
SELECT * FROM zhangwu WHERE zmoney >= 500 AND zmoney <= 1000;
-- 改造成between and 方式
SELECT * FROM zhangwu WHERE zmoney BETWEEN 500 AND 1000;

-- 查询金额是1000,3000,5000其中的一个
SELECT * FROM zhangwu WHERE zmoney = 1000 OR zmoney = 3000 OR zmoney = 5000
-- 改造成in方式 
SELECT * FROM zhangwu WHERE zmoney IN(1000,3000,5000);
SELECT * FROM zhangwu WHERE zmoney NOT IN(1000,3000,5000);


-- like 模糊查询
-- 查询所有的支出
SELECT * FROM zhangwu WHERE zname LIKE '支出';

-- 查询zhangwu名字，五个字符的（一个下划线_代表一个字符）
SELECT * FROM zhangwu  WHERE zname LIKE '_____';

-- 查询zhangwu名，不为空的
SELECT * FROM zhangwu WHERE zname IS NOT NULL;
SELECT * FROM zhangwu WHERE NOT (zname IS NULL);

/*
查询，对结果集进行排序
升序，降序，对指定列排序
order by 列名 [desc][asc]
desc 降序
asc 升序（默认为升序，一般可以不写）
*/
-- 查询zhangwu表，价格升序排列（ASC可以不写）
SELECT * FROM zhangwu ORDER BY zmoney ;
-- 查询zhangwu表，价格降序排列
SELECT * FROM zhangwu ORDER BY zmoney DESC;

-- 查询zhangwu表，查询所有的支出，对金额降序排列
-- 先过滤条件where 查询的结果再排序
SELECT * FROM zhangwu WHERE zname LIKE '%支出%' ORDER BY zmoney DESC;

