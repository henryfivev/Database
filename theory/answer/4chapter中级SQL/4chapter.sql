-- 4.1 本题中文版与英文版有不同，英文版a题目为列出授课数量，中文版题目为列出
-- 授课ID,应是中文版翻译错误。因英文版已有官网解答，以下以中文版为例

-- a. 显示所有教师的列表，使用外连接列出他们的ID，姓名以及所讲授课程的编号。
-- （没有授课的教师课程编号为0）

-- NOTE 因不同学期课程编号可能相同，因此使用DISTINCT ON去重。另外发现如有
-- ORDER BY语句，DISTINCT ON的属性集必须为ORDER BY的子集。
SELECT DISTINCT ON (id, name, course_id)
                    id, name, CASE
                              WHEN course_id IS NULL THEN '0'
                              ELSE course_id
                              END
FROM instructor NATURAL LEFT JOIN teaches
ORDER BY name, course_id, id;

-- NOTE COALESCE函数，有助于简化掉CASE NULL，很有帮助 ^_^~
SELECT DISTINCT ON (id, name, course_id)
                    id, name, COALESCE(course_id, '0') AS courseid
FROM instructor NATURAL LEFT JOIN teaches
ORDER BY name, course_id, id;

-- b. 使用标量子查询，不使用外连接实现上题。
SELECT DISTINCT ON (id, name, course_id)
                    id, name, course_id
FROM instructor NATURAL JOIN teaches
UNION
SELECT id, name , '0'
FROM instructor
WHERE id NOT IN (SELECT id FROM teaches)
ORDER BY name, course_id, id;

-- c. 显示2010年春季开设的所有课程的列表，包括教师姓名。如果课程段没有教师，教师名置为"——".
SELECT DISTINCT ON (course_id, name)
                    course_id, COALESCE(name, '——') AS name
FROM teaches NATURAL LEFT JOIN instructor
WHERE semester = 'Spring' AND YEAR = 2010
ORDER BY course_id, name;

-- d. 显示所有系的列表，包括每个系中教师的总数，不能使用标量子查询。确保正确
-- 处理没有教师的系。

SELECT dept_name, COUNT(id) AS total_teachers, building
FROM department NATURAL LEFT JOIN instructor
GROUP BY dept_name;

-- 4.2 不使用外连接运算重写下面每个SQL查询

-- a. select * from student natural left outer join takes
SELECT * FROM student NATURAL JOIN takes
UNION
SELECT id, name, dept_name, tot_cred, NULL, NULL, NULL, NULL, NULL FROM student
WHERE student.id NOT IN (SELECT id FROM takes);

-- b. select * from student natural full outer join takes
-- TODO 这里是不是有问题啊？takes.id是外键，参照student.id.即使是natural full outer join,结果应当与上题相同。

-- 4.3 假定有r(A,B),s(B,C),t(B,D),三个关系，所有属性声明非空。
--  r NATURAL LEFT OUTER JOIN (s NATURAL LEFT OUTER JOIN t);
-- (r NATURAL LEFT OUTER JOIN s) NATURAL LEFT OUTER JOIN t;

-- a. 给出关系r、s和t的实例,使得在第二个表达式的结果中，属性C有一个空值但属
-- 性D有非空值。

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS s;

DROP TABLE IF EXISTS r CASCADE;

CREATE TABLE r(a INT NOT NULL,
               b INT PRIMARY KEY);

CREATE TABLE s(b INT REFERENCES r(b),
               c INT NOT NULL);
CREATE TABLE t(b INT REFERENCES r(b),
               d INT NOT NULL);

INSERT INTO r
VALUES (9,10), (11,12), (13,14);

INSERT INTO s
VALUES(10, 100),(12,110);
INSERT INTO t
VALUES(10, 1000),(14,1400);

SELECT * FROM t;
SELECT * FROM s;
SELECT * FROM r;

SELECT * FROM (r NATURAL LEFT OUTER JOIN s)
              NATURAL LEFT OUTER JOIN t;

-- b. 在第一个表达式的结果中，上述模式中的C为空且D非空有可能吗？解释原因。
SELECT * FROM r
              NATURAL LEFT OUTER JOIN
              (s NATURAL LEFT OUTER JOIN t);

-- 答：不可能。因为所有属性非空；s自然左外连接t子句中,s.b = t.b且只显示s.b值，只有C、D均为NULL，或者C实D空两种可能。


-- 4.4 略

--4.5 结合习题3.2,定义视图 student_grades(ID,GPA)，给出每个学生的GPA.注意正确处理在takes关系的grade属性上取null值的情况。

-- 给出grade_points关系，转换grade到数字之间的转换。这里为了使之后操作直观，
-- 直接建表
DROP TABLE IF EXISTS grade_points;
CREATE TABLE grade_points(
    grade VARCHAR(2),
    points REAL);

INSERT INTO grade_points
VALUES ('A+', 4.33), ('A', 4.0), ('A-', 3.67), ('B+', 3.33),
       ('B', 3.0), ('B-',2.67), ('C+', 2.33), ('C', 2.0), ('C-', 1.67),
       ('D+', 1.33), ('D', 1.0), ('D-', 0.67), ('F', 0.0), (NULL, 0.0);
-- 偷懒，通过直接在grade_points对照表上直接加入NULL属性的方法，直接解决takes.grade为NULL的问题。

CREATE VIEW student_grades(ID, GPA) AS
    SELECT id, SUM(points * credits) / SUM(credits)
    FROM course NATURAL JOIN takes NATURAL JOIN grade_points
    GROUP BY ID;

-- 4.6  早已导入官网SQL，略。

-- 4.7 写出图4-11的SQL
DROP TABLE IF EXISTS works;
DROP TABLE IF EXISTS managers;
DROP TABLE IF EXISTS employee;

CREATE TABLE employee(
    employee_name text PRIMARY KEY ,
    street text,
    city text);

DROP TABLE IF EXISTS company;
CREATE TABLE compnay(
    company_name text PRIMARY KEY ,
    city text);

CREATE TABLE works(
    employee_name text REFERENCES employee PRIMARY KEY,
    company_name text REFERENCES company,
    salary text);

CREATE TABLE managers(
    employee_name text REFERENCES employee PRIMARY KEY ,
    manager_name text REFERENCES employee);

INSERT INTO employee VALUES ('zhangsan1', 'huancheng', 'tai');
INSERT INTO employee VALUES ('zhangsan2', 'huancheng', 'tai');
INSERT INTO employee VALUES ('zhangsan3', 'gugong', 'jing');
INSERT INTO employee VALUES ('zhangsan4', 'tian', 'te');
INSERT INTO employee VALUES ('zhangsan5', 'huancheng', 'tai');

INSERT INTO works VALUES ('zhangsan1', 'tao', 10000);
INSERT INTO works VALUES ('zhangsan2', 'tao', 10000);
INSERT INTO works VALUES ('zhangsan3', 'bao', 20000);
INSERT INTO works VALUES ('zhangsan4', 'tao', 30000);
INSERT INTO works VALUES ('zhangsan5', 'bao', 10000);

INSERT INTO company  VALUES ( 'tao', 'hell');
INSERT INTO company  VALUES ( 'bao', 'hell');

INSERT INTO managers VALUES ('zhangsan5', 'zhangsan1');
INSERT INTO managers VALUES ('zhangsan1', 'zhangsan2');

-- 4.8 “每位教师不能在同一个学期的同一个时间段在两个不同的教室授课”

-- a. 找出违反约束的所有(instructor, section)组合。

-- 这题费神较多，官网答案在PSQL中报错无法执行，我使用了自连接方法。

WITH fuck AS (
SELECT * FROM instructor NATURAL JOIN teaches NATURAL JOIN SECTION)
SELECT fuck1.* FROM fuck AS fuck1 JOIN fuck AS fuck2
                                       USING (year, semester, sec_id, id, time_slot_id)
WHERE fuck1.room_number <> fuck2.room_number;

-- b. PSQL不支持断言方法，略。

-- 4.9 第六版中文版4.9题有误。以下为第七版英文版原题：
-- SQL allows a foreign-key dependency to refer to the same relation, as in the following example:

create table manager
(
  employee_id char(20),
  manager_id char(20),
  primary key employee_id,
  foreign key ( manager_id ) references manager(employee_id)
on delete CASCADE )
-- Here, employee_id is a key to the table manager,
-- meaning that each employee has at most one manager. The foreign-key
-- clause requires that every manager also be an employee. Explain exactly
-- what happens when a tuple in the relation manager is deleted.

  -- 答：因为外键manager参照本关系中的employee_id且是ON DELETE CASCADE.
  -- 因此当某元组被删除时，除被删除元组manager外，元组中employeeJD至下各级员工均被删除。

-- 4.10 COALESCE(a1,a2,a3,...,an)返回序列中的第一个非空值.假设A和B模式分别为 A(name, address, title)和B(name,address,salary)的关系。如何用带on条件和COALESCE运算的全外连接运算来表达a NATURAL FULL OUTER JOIN b.要保证结果关系中不包含name和address的两个副本，并且即使A和B中的某些元组在属性name和address取空值的情况下，解决方案仍然是正确的。

  -- TODO 这个题我没有做出来，直接看的答案。反映出对自然全外连接的理解不足。
  -- 自然全外连接其实就是自然内连接，加上双方各自独有的元组。既然独有，则对方相应属性为NULL。所以可以用COALESCE


DROP TABLE IF EXISTS A;
CREATE TABLE A(name text, address text, title text);
DROP TABLE IF EXISTS B;
CREATE TABLE B(name text, address text, salary int);

INSERT INTO A VALUES ('zhangsan', 'jing', 'laji');
INSERT INTO A VALUES ('lisi', 'jin', 'guojiang');
INSERT INTO A VALUES ('wang5', 'ji', 'caifeng');
INSERT INTO B VALUES ('wang5', 'ji', 100);
INSERT INTO B VALUES ('lisi', 'jin', 200);
INSERT INTO A VALUES (NULL, 'jing', 'laji');
INSERT INTO B VALUES ('zhao6', NULL, 300);
INSERT INTO B VALUES (NULL, NULL, 400);

INSERT INTO B VALUES('wang5', 'hell' , NULL);
INSERT INTO B VALUES('wang5', NULL , NULL);

SELECT * FROM A NATURAL FULL OUTER JOIN B;

SELECT COALESCE(A.name, B.name) AS name,
       COALESCE(A.address, B.address) AS address,
       title,
       salary
  FROM A FULL OUTER JOIN B ON(A.name = B.name AND A.address = B.address);

  -- 4.11 带标记空值，通过视图 instructor_info 插入

  -- Some researchers have proposed the concept of marked nulls. A marked
-- null ⊥i is equal to itself, but if i != j, then ⊥i != ⊥j . One
-- application of marked nulls is to allow certain updates through views.
-- Consider the view instructor_info (Section 4.2 Views).
-- Show how you can use marked nulls to allow the insertion of the tuple
-- (99999, “Johnson”, “Music”) through instructor_info.

  -- section 4.2的视图.注意：SQL标准中，null = null的值仍为null.
  CREATE VIEW instructor_info AS
  SELECT id,name,building
           FROM instructor, department
                  WHERE instructor.dept_name = department.dept_name;
-- 题意不清。看答案了解到此题其实是设计视图插入 $⊥_特定$ 的原理。如上例视图
-- 靠dpet_name连接,则向视图插入时，直接将⊥_i 同时插入到instructor.dept_name
-- 和department.dept_name.两个带标记空值相等，因此可以在视图中显现出来。

-- 4.12 对于图4.11（参照问题4.7的答案），写出一个查询找出没有经理的雇员。注
-- 意一个雇员可能没有经理，也可能经理为null.分别使用外连接和不使用外连接写出
-- 查询。

-- 这题目其实是有问题的，参照图11和问题7,managers_name是参照employee主键的外
-- 键，其实不可能有NULL值.这里姑且当其有吧。

SELECT * FROM employee;
SELECT * FROM managers;

SELECT employee_name
  FROM employee NATURAL LEFT OUTER JOIN managers
 WHERE manager_name IS NULL;

SELECT employee_name FROM employee
 WHERE employee_name NOT IN (SELECT employee_name FROM managers)
       OR
       employee_name IN (
         SELECT employee_name FROM managers
          WHERE manager_name IS NULL );

-- 4.13 什么情况下，以下查询将包含在属性title上取空值的元组
SELECT *
  FROM student NATURAL FULL JOIN takes
                                   NATURAL JOIN course ;
-- 1. title本身取空值
-- 2. student.id取值 不在takes.id中。
-- 3. TODO FIXME 根据此示例数据库，不知还有什么答案，可能有遗漏。

-- 4.14 如何定义视图tot_credits(year, num_credits)给出学生修到的学分总数

-- 本题是接着3.2课后题而来。

-- 首先给出grade_points关系，转换grade到数字之间的转换。
DROP TABLE IF EXISTS grade_points;
CREATE TABLE grade_points(
    grade VARCHAR(2),
    points REAL);
INSERT INTO grade_points
VALUES ('A+', 4.33), ('A', 4.0), ('A-', 3.67), ('B+', 3.33),
       ('B', 3.0), ('B-',2.67), ('C+', 2.33), ('C', 2.0), ('C-', 1.67),
       ('D+', 1.33), ('D', 1.0), ('D-', 0.67), ('F', 0.0);

-- 创建视图
DROP VIEW IF EXISTS tot_credits;
CREATE VIEW tot_credits(year, num_credits) AS (
SELECT year, SUM(points * credits)
FROM course NATURAL JOIN takes NATURAL JOIN grade_points
 GROUP BY(YEAR)
ORDER BY (year));

-- 测试
SELECT * FROM tot_credits;

-- 4.15 简单，略

-- 4.16 本题其实考察的是类似于一个外键参照另外两个关系中的属性。

-- 当前PostgreSQL CHECK表达式不能包含子查询，也不能引用当前行的列之外的变量（参
-- 见 “检查约束”一节）。可以引用系统列tableoid，但不能引用其他系统列。支持
-- CHECK(子查询),因此不能使用CHECK检测.

-- 双外键也不行。经实验，PSQL中只有两个被参考属性的交集才能被插入 -___-

-- TODO FIXME 不知除了触发器或通过函数插入还有什么办法。

-- 4.17 但一个经理如Satoshi授予他人权限的时候，授权应由经理角色完成，而不是
-- 由用户Satoshi完成。解释其原因。

-- 答：如果由用户Satoshi授权，则Satoshi被撤销权限后，其对其他用户直接或间接
-- 授予的权限都将被删除。所以应当由经理角色来授权。

-- 4.18 假定用户A拥有关系r上的所有权限.该用户把关系r上的查询权限以及with
-- grant OPTION 赋予public.假定之后B又将r关系上的select关系赋予给A,请问这是否会导致授权图中的环。

-- 答：public匹配数据库当前与将来用户。授权后B也获得了相应
-- 权利，PSQL只支持把授权选项授予给角色，不允许授权给public。

-- 将向public授权更改为直接向B授权后，经实验会导致授权图中的环。另外，起码在
-- PSQL中，删除已赋予其他用户权限的用户,往往要借用REASSIGN OWNED和DROP OWNED命令。
