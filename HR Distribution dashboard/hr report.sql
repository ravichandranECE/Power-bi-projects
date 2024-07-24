create database projects;
use projects;
select * from hr;
describe hr;
select birthdate from hr;

update hr
set birthdate=case
when birthdate like "%/%" then date_format(str_to_date(birthdate,"%m/%d/%Y/%"),"%Y-%m-%d")
when birthdate like "%-%" then date_format(str_to_date(birthdate,"%m-%d-%Y-%"),"%Y-%m-%d")
else null
end;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

alter table hr modify column hire_date date;

select birthdate from hr;

alter table hr modify column birthdate date;

describe hr;

select termdate from hr;

update hr 
set termdate = date (str_to_date(termdate,"%Y-%m-%d %H:%i:%s UTC"))
where termdate is not null and termdate != ' ';
select termdate from hr;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '0000-00-00 00:00:00 UTC';

update hr 
set termdate="0000-00-00" WHERE termdate=" ";
update hr 
set termdate="0000-00-00" WHERE termdate='0000-00-00 00:00:00 UTC';
 
select * from hr;
alter table hr modify column termdate date;
 
-- add age column --
alter table hr add column age int;

update hr
set age = timestampdiff(year,birthdate, curdate()) order by age asc;

select birthdate, age from hr;

alter table hr add column age_group text;
alter table hr drop column age_group;

update hr set age_group =
case 
when age>=18 and age<=24 then "18-24"
when age >=25 and age<=34 then "25-34"
when age >=35 and age<=44 then "35-44"
when age>=45 and age <=54 then "45-54"
when age>=55 and age <=65 then "55-65"
else "above 65"
end ;

select age, age_group from hr;


select min(age) as youngest,
max(age) as oldest from hr;

select * from hr;


-- Questions; --
-- 1. what is the gender breakdown of the employees in the company?
select gender, count(*)  from hr where age >=18  and termdate = "0000-00-00"
 group by gender;
 
-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*)as count from hr where age>=18 and termdate="0000-00-00" group by race order by count desc;

-- 3. What is the age distribution of employees in the company?
select min(age), max(age) from hr where age>=18 and termdate="0000-00-00";
select case
when age>18 and age<24 then "18-24"
when age >25 and age<34 then "25-34"
when age >35 and age<44 then "35-44"
when age>45 and age <54 then "45-54"
when age>55 and age <65 then "55-65"
else "65+"
end as age_group,
count(*) as count,gender from hr where age>=18 and termdate ="0000-00-00" group by age_group,gender order by age_group,gender;


-- 4. How many employees work at headquarters versus remote locations?
select location , count(*) as count  from hr where age>=18 and termdate="0000-00-00" group by location order by count desc;

-- 5. What is the average length of employment for employees who have been terminated?
select round(avg(datediff(termdate,hire_date))/365,0) from hr where termdate != "0000-00-00" and age>=18 and termdate<curdate();

-- 6. How does the gender distribution vary across departments and job titles?
select department,gender, count(*) as count from hr where age>=18 and termdate="0000-00-00" group by gender,department order by department; 

-- 7. What is the distribution of job titles across the company?
select * from hr;
select jobtitle,count(*) as count from hr where age>=18 and termdate="0000-00-00" group by jobtitle order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
/* "Turnover rate" typically refers to the rate at which employees leave a company or
 department and need to be replaced. It can be calculated as the number of employees
 who leave over a given time period divided by the average number of employees in the
 company or department over that same time period.*/
select department, count(*) as total_count,
sum(case when termdate!="0000-00-00" and termdate<=curdate() then 1 else 0 end ) as termination_count,
sum(case when termdate="0000-00-00" then 1 else 0 end ) as active_count,
(sum(case when termdate<curdate() then 1 else 0 end )/count(*)) as termination_rate
 from hr
 where age>=18
 group by department
 order by termination_rate;
 
 -- 9. What is the distribution of employees across locations by state?

 select location_state , count(*)as count  from hr where age>=18 and termdate="0000-00-00" group by location_state order by count desc;
 
 
 -- 10. How has the company's employee count changed over time based on hire and term dates?
 /* This query groups the employees by the year of their hire date and calculates the total number of hires, terminations, 
 and net change (the difference between hires and terminations) for each year. The results are sorted by year in ascending order.*/
 
 select year(hire_date), count(*) as hires,
 sum(case when termdate!="0000-00-00" and termdate<curdate() then 1 else 0 end ) as termination,
 count(*)-sum(case when termdate!="0000-00-00" and termdate<curdate() then 1 else 0 end) as net_change,
 round(((count(*)-sum(case when termdate!="0000-00-00" and termdate<curdate() then 1 else 0 end))/count(*))*100,2) as net_change_precent from hr
 where age>=18 group by year(hire_date) order by year(hire_date) asc;
 
 
 select years,hires, termination, (hires-termination) as net_change,
 round(((hires-termination)/hires*100),2) as net_change_percent
 from 
 (
 select year(hire_date) as years, count(*) as hires,
 sum(case when termdate!="0000-00-00" and termdate<=curdate() then 1 else 0 end ) as termination
from hr
  where age>=18
  group by year(hire_date)
  ) x
  order by years asc;
  
  -- 11. What is the tenure distribution for each department?
  -- How long do employees work in each department before they leave or are made to leave?
  select * from hr;
  select department, round(avg(datediff(curdate(),termdate)/365),0) as avg_tenure
  from hr
  where age>=18 and termdate<curdate() and termdate!="0000-00-00" group by department;
  
  