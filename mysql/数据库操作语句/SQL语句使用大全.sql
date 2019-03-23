/*
SQL语句使用大全
*/
-- 数据库操作语句
-- 1、创建数据库，并指定编码
CREATE DATABASE test CHARACTER SET utf8;
-- 2、查看数据库
SHOW DATABASES;
-- 3、使用数据库
USE test;
-- 4、删除数据库
DROP DATABASE test;

-- 表操作语句
-- 1、创建表,至少要包含一列
CREATE TABLE test(id INT PRIMARY KEY AUTO_INCREMENT,
NAME VARCHAR(10));
-- 2、查看当前数据库中的表
SHOW TABLES;
-- 3、查看表结构 desc
DESC test;
-- 4、向表中插入数据 insert
INSERT INTO test(NAME)VALUES('lisi');
-- 5、查看表中全部数据 select
SELECT * FROM test;
-- 6、修改表的结构，向表中添加一列 alter add
ALTER TABLE test ADD pass VARCHAR(10);
-- 7、修改表的结构，删除表中的列
ALTER TABLE test DROP pass;
-- 8、修改表中列名 alter change
ALTER TABLE test CHANGE pass PASSWORD VARCHAR(10);
-- 9、修改指定列的限定符  alter modify
ALTER TABLE test MODIFY PASSWORD VARCHAR(12) ;
-- 10、修改表的字符集
ALTER TABLE test CHARACTER SET utf8;
-- 10、修改表名 rename
RENAME TABLE test1 TO test; 
-- 11、删除记录
DELETE FROM test WHERE id=2;
DELETE FROM test;
-- 12、清空表
TRUNCATE TABLE test;
-- 13、删除表
DROP TABLE test;
USE gjp;

-- 根据条件查看表中数据 select 字段 from 表名 where 条件;
SELECT * FROM gjp_zhangwu WHERE zwid=1;
SELECT flname,money FROM gjp_zhangwu WHERE zwid=1;
-- 显示在某一区间的值（含头含尾）between and
SELECT zwid,flname,money FROM gjp_zhangwu WHERE zwid BETWEEN 1 AND 5;
-- 显示在in列表中的值，in（）
SELECT zwid,flname,money FROM gjp_zhangwu WHERE zwid IN(1,2,5);
-- like通配符
-- %用来匹配字符
SELECT * FROM gjp_zhangwu WHERE flname LIKE '%收入';   -- flname中以收入结束的都符合查询
SELECT * FROM gjp_zhangwu WHERE flname LIKE '工资%';   -- flname中以工资开头的都符合查询
SELECT * FROM gjp_zhangwu WHERE flname LIKE '%工资%';   -- flname中只要包含工资的都符合查询
-- _用来匹配字符个数
SELECT * FROM gjp_zhangwu WHERE zhanghu LIKE '____';    -- zhanghu中为四个字符的否符合查询

-- 聚合
-- 统计表中有多少条记录 count（*）
SELECT COUNT(*) FROM gjp_zhangwu;
-- count(*) where
SELECT COUNT(*) FROM gjp_zhangwu WHERE money>5000;  -- 统计表中money>5000的记录条数
-- 统计表中的总收入 sum() where
SELECT SUM(money) FROM gjp_zhangwu WHERE flname LIKE '%收入%';
-- 统计表中收入的平均值
SELECT AVG(money) FROM gjp_zhangwu WHERE flname LIKE '%收入%';

-- 分组select 字段1，字段2...from 表名 group by 字段 having 条件
-- 分组求和  select 字段1，字段2...,sum() from 表名 group by 字段
SELECT flname,SUM(money) FROM  gjp_zhangwu GROUP BY flname;
-- 分组求和并排序 
SELECT flname,SUM(money) AS 'getsum' FROM  gjp_zhangwu GROUP BY flname ORDER BY getsum ;
-- 分组求和，并过滤 select 字段1，字段2...,sum() from 表名 group by 字段 having 条件
-- as 对求和列进行临时命名
SELECT flname,SUM(money)AS 'getsum' FROM  gjp_zhangwu GROUP BY flname HAVING getsum>5000;



