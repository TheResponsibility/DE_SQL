/*
Поднималась виртуальная тачка на Центосе, на неё ставился постгря 15, открывался FW на 5432, дописывался файл
pg_hba.conf, postgresql.conf.
Работа велась через HeidiSQL по порту 5432, который был открыт под это дело.

Пояснение по логике порядка формирования отделов и стаффа:
В данном случае, для пикантности генерируются отделы, ставятся люди, потом дописывается список сотрудников,
потому как назначить сотрудника в несуществующий ПО ДАННОМУ КОНТЕКСТУ отделу — невозможно. Спорный вопрос про руководителя,
если не создан стафф, согласен. Дополнительно вяжется ключ. 

Потом идет пересчет численности отделов после добавления сотрудников.
*/


DROP TABLE IF EXISTS staff;

DROP TABLE IF EXISTS departments;

DROP TABLE IF EXISTS KPI;

DROP FUNCTION IF EXISTS random_kpi;


-------------- task 2.1 --------------

CREATE TABLE departments
(
	id SMALLINT generated always as identity primary key, 
	dep_name VARCHAR(50) not NULL, 
	leader VARCHAR(50) not NULL, 
	count_of_members SMALLINT DEFAULT NULL
);


INSERT INTO departments (dep_name, leader)
VALUES
	('Accounting','Odinassovna Tamara Georgievna'),
	('Development','Ivanov Petr Stepanovich'),
	('Convoy','Gosling Ryan Thomas')
;

-------------- task 1 --------------

CREATE TABLE staff
(
	id SMALLINT generated always as identity primary key, 
	fullname varchar(100) not NULL, 
	birthday date not NULL, 
	begin_work date not NULL, 
	job_title varchar(10) not NULL, 
	job_level varchar(15) not NULL,
	salary real not NULL, 
	department_id SMALLINT not NULL, 
	is_admin boolean NOT NULL DEFAULT FALSE,
	constraint dep_worker FOREIGN KEY (department_id) REFERENCES departments (id)
);


INSERT INTO staff (fullname, birthday, begin_work, job_title, job_level, salary, department_id, is_admin)
VALUES
	('Timiryazov Petr Georgievich', '12-12-1999', '01-01-2019', 'developer', 'jun', 75000, 2, FALSE),
	('Petrova Tatiana Valeryevna', '10-02-1997', '02-04-2016', 'developer', 'middle', 110000, 2, FALSE),
	('Rustemov Ashot Ashotovich', '12-08-1994', '10-19-2016', 'developer', 'jun', 85000, 2, FALSE),
	('Spinov Oleg Vladimirovich', '01-07-1992', '07-10-2017', 'developer', 'middle', 155000, 2, FALSE),
	('Devopsinov Vladimir Vyascheslavovich', '12-02-1987', '03-08-2016', 'engineer','senior', 255000, 2, TRUE),
	('Koroleva Natalia Ivanovna', '05-18-1988', '04-24-2018', 'developer','middle', 175000, 2, FALSE),
	('Ivanov Petr Stepanovich', '03-10-1989', '03-01-2017', 'developer', 'lead', 275000, 2, FALSE),
	
	('Popova Svetlana Ivanovna', '05-18-1955', '01-23-2016', 'accountant','senior', 58000, 1, FALSE),
	('Odinassovna Tamara Georgievna', '03-10-1961', '02-01-2016', 'accountant', 'senior', 66000, 1, FALSE),
	
	('Petrov Petr Ivanovich', '05-18-1992', '03-07-2016', 'driver','jun', 35000, 3, FALSE),
	('Gosling Ryan Thomas', '12-11-1980', '02-01-2017', 'driver', 'senior', 57000, 3, FALSE)
;


-------------- task 2.2 --------------

UPDATE departments AS dep
SET count_of_members = s_count.count_of_members
FROM 
(
	SELECT 
		department_id,
		COUNT(department_id) AS count_of_members
	FROM staff
	GROUP BY 1
	ORDER BY 1 ASC
	) s_count 
WHERE s_count.department_id = dep.id;

-------------- task 3 --------------

CREATE FUNCTION random_kpi() RETURNS VARCHAR(1) LANGUAGE sql AS 
$$
  SELECT string_agg (SUBSTR('ABCDE', CEIL (RANDOM() * 5)::INTEGER, 1),'')
  FROM GENERATE_SERIES(1, 10)
$$;

CREATE TABLE KPI AS 
SELECT *, 
left(random_kpi(),1) AS exam
FROM (VALUES (1), (2), (3),(4)) AS q (quarters)
CROSS JOIN (SELECT fullname FROM staff) tt;

-------------- task 5 --------------

INSERT INTO departments (dep_name, leader)
VALUES
	('Data Mining','Servantes Migel DE_Saavedra');
	
	
INSERT INTO staff (fullname, birthday, begin_work, job_title, job_level, salary, department_id, is_admin)
VALUES
	('Servantes Migel DE_Saavedra', '12-12-1986', '02-10-2022', 'developer', 'lead', 175000, 4, FALSE);
	
	
SELECT * FROM staff;

UPDATE departments AS dep
SET count_of_members = s_count.count_of_members
FROM 
(
	SELECT 
		department_id,
		COUNT(department_id) AS count_of_members
	FROM staff
	GROUP BY 1
	ORDER BY 1 ASC
	) s_count 
WHERE s_count.department_id = dep.id;

/*
SELECT * FROM departments;	
SELECT * FROM kpi;
*/

-------------- task 6.1 --------------
SELECT 
	id,
	fullname,
	AGE(NOW(),begin_work) AS work_expirience
FROM staff;	

-------------- task 6.2 --------------
SELECT 
	id,
	fullname,
	AGE(NOW(),begin_work) AS work_expirience
FROM staff
ORDER BY AGE(NOW(),begin_work) DESC 
LIMIT 3;	
-------------- task 6.3 --------------

SELECT id
FROM staff
WHERE job_title LIKE '%driv%';

-------------- task 6.4 --------------

SELECT DISTINCT(s.id)
FROM kpi
LEFT JOIN (SELECT id,fullname FROM staff) s ON kpi.fullname = s.fullname
WHERE kpi.exam IN ('D','E');

-------------- task 6.5 --------------
SELECT MAX(salary)
FROM staff;

-------------- task 6.6 --------------
SELECT id
FROM staff
ORDER BY AGE(NOW(),begin_work) DESC;

-------------- task 6.7 --------------

SELECT 
	ROUND(AVG(salary)) AS avg_salary, 
	job_level
FROM staff 
GROUP BY 2
ORDER BY 1 DESC;

-------------- task 6.8 --------------
ALTER TABLE kpi ADD COLUMN IF NOT EXISTS exam_value FLOAT;

UPDATE kpi
SET exam_value =
   CASE 
	WHEN exam = 'A' THEN 1.2 
	WHEN exam = 'B' THEN 1.1 
	WHEN exam = 'C' THEN 1.0 
	WHEN exam = 'D' THEN 0.9 
	WHEN exam = 'E' THEN 0.8  
END;
SELECT * FROM kpi;


WITH reward_cte AS(
SELECT 
	fullname,
	ROUND(CAST(SUM(exam_value)/4 AS NUMERIC),2) AS reward
FROM kpi
GROUP BY 1)

SELECT
	fullname,
	ROUND(CAST(salary*reward AS NUMERIC),3) AS year_reward
FROM
(
SELECT 
	s.fullname,
	s.salary,
	rc.reward
FROM staff s
LEFT JOIN reward_cte rc ON s.fullname=rc.fullname 
) ttt