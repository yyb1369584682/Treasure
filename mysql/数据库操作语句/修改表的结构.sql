/*
创建数据库
create database 数据库名
*/
CREATE DATABASE mybase;
/*
使用某个数据库
use 数据库名
*/
USE mybase;
/*
创建数据库表的格式

create table 表名(
	列名1 数据类型 约束，
	列名2 数据类型 约束，`users`
	列名3 数据类型 约束
);
创建用户表，用户编号，姓名，用户的地址
将编号列，设置为主键约束，保证列的数据唯一性，非空性
primary key 
让主键列数据，实现自动增长
*/
CREATE TABLE users(
	uid INT PRIMARY KEY AUTO_INCREMENT,
	uname VARCHAR(20),
	uaddress VARCHAR(200)
);
/*
show table 显示所有表
*/
SHOW TABLE;
/*
desc table 显示表结构
*/
DESC users;
/*
添加列，添加字段
alter table 表名 add 列名 数据类型 约束
*/
ALTER TABLE users ADD tel INT;

/*
修改列，在原有的列上修改
修改列名，数据类型约束
alter table 表名 modify 列名 数据类型 约束
*/
ALTER TABLE users MODIFY tel VARCHAR(50);

/*
修改列名
alter table 表名 change 旧列名 新列名 数据类型 约束
*/
ALTER TABLE users CHANGE tel newtel DOUBLE;

/*
删除列(若其中有数据的话，数据也被删除)
alter table 表名 drop 列
*/
ALTER TABLE users DROP newtel;

/*
修改表名
rename table 表名 to 新表名
*/
RENAME TABLE users TO newusers;



