/*
使用聚合函数查询计算
*/

-- count 求和，对表中的数据的个数求和 count（列名）
-- 查询统计zhangwu表中，一共有多少条数据
SELECT COUNT(*) AS COUNT FROM zhangwu;

-- sum求和，对一列中数据进行求和计算sum(列名)
-- 对zhasngwu表查询，对所有的金额求和计算
SELECT SUM(zmoney) FROM zhangwu;
-- 求和，统计所有支出的总金额
SELECT SUM(zmoney) FROM zhangwu WHERE zname LIKE '%支出%';

-- 求平均数(对于null值的记录直接不进行处理)
INSERT INTO zhangwu (id,zname,zmoney) VALUES (8,'彩票',NULL);
SELECT AVG(zmoney) FROM zhangwu ;

/*
分组查询: group by 被分组的列名
必须跟随聚合函数
select 查询的时候，被分组的列，要出现在select选择列的后面
*/
SELECT SUM(zmoney),zname FROM zhangwu GROUP BY zname;

-- 对zname内容进行分组求和，但只要支出
SELECT SUM(zmoney) AS 'getsum' ,zname FROM zhangwu WHERE zname LIKE '%支出%'
GROUP BY zname ORDER BY getsum DESC

-- 对zname内容进行分组求和，但只要支出,显示金额大于500的
SELECT SUM(zmoney) AS 'getsum' ,zname FROM zhangwu WHERE zname LIKE '%支出%'
GROUP BY zname HAVING getsum > 500;