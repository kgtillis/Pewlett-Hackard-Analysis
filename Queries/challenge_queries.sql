-- Pewlett-Hackard-Analysis Challenge

-- TABLE 1: Number of Retiring Employees by Title
-- Creating retirement_ready Table and expected position
-- vacancies.

-- Table created to gather currently employed, retirement
-- eligible employees
SELECT
	e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	s.salary
INTO retirement_sort
FROM current_emp as e
INNER JOIN salaries AS s
ON (e.emp_no = s.emp_no)
INNER JOIN titles AS ti
ON (e.emp_no = ti.emp_no)
order by e.emp_no;

select * from retirement_sort;

--- Table created to filter for duplicate of employees and 
--- selecting most current job tite. 
SELECT 
	emp_no,
 	first_name,
 	last_name,
 	title, 
	from_date,
	salary
INTO retirement_ready
FROM
 	(SELECT 
	 	emp_no,
		first_name,
		last_name,
 		title,
	 	from_date,
	 	salary,
	ROW_NUMBER() OVER
 		(PARTITION BY (emp_no)
 		ORDER BY from_date DESC) rn
 		FROM retirement_sort
 	) tmp WHERE rn = 1
ORDER BY title ASC, emp_no ASC;

select * from retirement_ready;

-- Count of Retirement Ready Employees
SELECT 
	COUNT(emp_no)
FROM retirement_ready

-- Number of Retiring Employees by Title
SELECT 
	title,
	COUNT(title)
INTO expected_vacancies
FROM retirement_ready
GROUP BY title
ORDER BY title ASC;

select * from expected_vacancies;

--- TABLE 2: Table 2: Mentorship Eligibility

--- Creating table of currently employed employees with
--- birth year of 1965 to become mentors for the mentorship program.

-- Selecting required information of employees and filtering by:
-- current employee and 1965 birth date. 
select
	e.emp_no,
	e.first_name,
	e.last_name, 
	ti.title,
	de.from_date,
	de.to_date, 
	e.birth_date
INTO emp_birth_sort
FROM employees as e
LEFT JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
LEFT JOIN titles as ti
ON (e.emp_no = ti.emp_no)
WHERE (de.to_date = ('9999-01-01'))
	AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31');

select * from emp_birth_sort;

-- Filtering out the duplicate titles to have most current title. 
SELECT 
	emp_no,
 	first_name,
 	last_name,
 	title, 
	from_date,
	to_date
INTO mentorship_eligibility
FROM
 	(SELECT 
	 	emp_no,
		first_name,
		last_name,
	 	title,
	 	from_date,
	 	to_date,
	ROW_NUMBER() OVER
 		(PARTITION BY (emp_no)
 		ORDER BY to_date DESC) rn
 		FROM emp_birth_sort
 	) tmp WHERE rn = 1
ORDER BY emp_no;

select * from mentorship_eligibility;

-- Count of Mentorship Elegible Employees
SELECT 
	COUNT(emp_no)
FROM mentorship_eligibility