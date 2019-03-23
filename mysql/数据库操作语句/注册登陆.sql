/*
创建用户数据库
名字：user_data
*/
CREATE DATABASE user_data;
/*
/创建用户表，用于存储用户名和密码
名字：users
三个列：主键，用户名，密码
*/
USE user_data;
CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(50) NOT NULL,
PASSWORD VARCHAR(50) NOT NULL
);

INSERT  INTO users(username,PASSWORD) VALUES('a','1'),('b','2');
SELECT username FROM users WHERE username='a';
SELECT * FROM users;
DROP TABLE users;