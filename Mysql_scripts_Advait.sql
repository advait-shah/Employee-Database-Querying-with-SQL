-- We will be using the mansci database, so please click on it. There, you will find the following tables:
-- emp, dept, works

-- Our schemas:
--
-- 1 emp:
-- 1.1 eid	INT
-- 1.2 ename	VARCHAR
-- 1.3 age	INT
-- 1.4 salary	INT
-- 
-- 2 dept:
-- 2.1 did	INT
-- 2.2 dname	VARCHAR
-- 2.3 budget	INT
-- 2.4 managerid INT (FK emp.eid)
--
-- 3 works:
-- 3.1 eid	INT (FK emp.eid)
-- 3.2 did	INT (FK dept.did)
-- 3.3 pct_time INT [the percentage of time the employee works in this dept] 

-- Q1
-- Print the employee ID and name for all employees, ordered by ascedning order of names.
SELECT eid AS Employee ID, ename AS [Employee Name]
FROM `emp`
ORDER BY ename ASC;

-- Q2
-- Print the employee ID and name for all employees whose salary is more than $40,000, ordered by ascedning order of names.
SELECT eid, ename
FROM `emp`
WHERE salary > 40000
ORDER BY ename ASC;

-- Q3 
-- Print the number of employees whose salary is more than $40,000. Name the column "Employees paid more than $40,000".
SELECT COUNT(*) AS `Emplyees paid more than $40,000`
FROM `emp`
Where salary > 40000;

-- Q4
-- Print the name of each department and the name of its manager.
select d.dname AS departmentName , e.ename As ManagerName
from emp e
inner join dept d on e.eid = d.managerid;


-- Q5
-- Print the number of employees in each department.
select count(*) AS `NumberOfEmployees`, dept.dname AS DepartmentName
from dept natural join works
group by works.did
ORDER BY `NumberOfEmployees` DESC;

-- Q5.1
-- Print the percentage of employees in each department.
-- Next week we will incorporate pct_time

select count(*)/ (select count(*) AS totalNumEmp FROM emp)*100 AS `Percentage Of Employees`, dept.dname AS DepartmentName
from dept natural join works
group by works.did
ORDER BY `Percentage Of Employees` DESC;


-- Q6
-- Print the minimum and maximum salary per department
select MIN(emp.salary) AS MinSalary, MAX(emp.salary) AS MaxSalary, dept.dname
from works natural join emp natural join dept
GROUP BY dept.did;

-- Q7
-- Print the difference between the department's budget and the total salaries its pays.
select d.budget-sum(e.salary*w.pct_time/100), d.dname
from works w natural join emp e natural join dept d
group by w.did;

-- Q8
-- Print the names and ages of each employee who works in both the Hardware department and the Software department.
select e.ename, e.age
from works w natural join emp e natural join dept d
where d.dname = 'Hardware' and e.eid in (select w2.eid from works w2 natural join dept d2 where d2.dname = 'Software');

-- Q9
-- Print the name of each employee whose salary exceeds the budget of all of the departments that he or she works in.
select e.ename
from emp e
where e.salary > ALL(
    SELECT d.budget FROM dept d, works w
    where w.eid = e.eid and d.did = w.did 
);

-- Q10
-- Find the enames of managers who manage the departments with the largest budgets.

select e.ename
from emp e
where e.eid in (
    select d.managerid
    from dept d
    where d.budget >= ALL(
        select d2.budget
        from dept d2
    )
);

--OR

select e.ename
From emp e
where e.eid IN (
    select d.managerid
    from dept d
    where d.budget = (
        select max(d2.budget)
        from dept d2
    )
);

--OR

select e.ename AS MaxBudgetManager
from emp e inner join dept d on e.eid = d.managerid
where d.budget = (
    select max(d2.budget)
    from dept d2);

-- Q11
-- Print the employees who do not work in any department.
select e.eid, e.ename
from emp e
where e.eid not in (
    select distinct w.eid
    from works w);

-- Q12
-- Print the avg salary of employees who do not work in the Software department.

---------------------------------------
/* solution-1 (which does not consider salary of employees 
working in other departmenet along with software): */
select avg(e.salary)
from emp e
where e.eid not in (
    select w2.eid
    from dept d2 natural join works w2
    where d2.dname = "Software"
    );
---------------------------------------

/* solution-2 (which considers salary of employees 
working in other departmenet along with software): */
SELECT AVG(salary)
FROM emp
NATURAL JOIN works NATURAL JOIN dept
WHERE dname <> 'Software';
----------------------------------------

-- Q13
-- Print the names of employees who work in more than one department.

---------------------------------------
/* solution-1 (which repeats required names n times as per involved departments counts): */
select e.ename
from emp e natural join works w
where exists (
    select w2.eid
    from works w2 natural join emp e2
    where e.eid=e2.eid and w.dname <> w2.dname
);
--------------------------------------

/* solution-2: */

select count(*) AS NumberOfInvolvedDepartment, e.ename
from emp e natural join works w
group by w.eid
having count(*)>1;
--------------------------------------