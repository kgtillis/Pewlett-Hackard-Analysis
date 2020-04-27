-- MODULE 7 LESSON -- 

-- Retirement Years
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Retirement eligibility - Create New Table Retirement Info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create new table for retiring employees with employee number
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no; 

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
de.to_date
INTO current_emp 
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no 
WHERE de.to_date = ('9999-01-01');

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO employee_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Current Employees eligible for retirement
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 AND (de.to_date = '9999-01-01');
	 
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);

-- Employees per department
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name	
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);

-- Creating Sales Info tables 7.3.6
SELECT 
	ri.emp_no,
	ri.first_name,
	ri.last_name,
	di.dept_name
--INTO sales_info
FROM retirement_info as ri
INNER JOIN dept_info as di
ON (ri.emp_no = di.emp_no)
WHERE (di.dept_name = 'Sales');

SELECT 
	ri.emp_no,
	ri.first_name,
	ri.last_name,
	di.dept_name
--INTO sales_dev_info
FROM retirement_info as ri
INNER JOIN dept_info as di
ON (ri.emp_no = di.emp_no)
WHERE (di.dept_name in ('Sales', 'Development'));

-- END OF MODULE 7 LESSON -- 

-- CHALLENGE TABLE 1: Number of Retiring Employees by Title
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

-- Number of Retiring Employees by Title
SELECT 
	title,
	COUNT(title)
--INTO expected_vacancies
FROM retirement_ready
GROUP BY title
ORDER BY title ASC;

select * from expected_vacancies;

---- CHALLENGE TABLE 2: Table 2: Mentorship Eligibility
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