****Fourth report*****;

/*Get only the employee*/
data fourth_report;
set orion.order_product_emp;
if employee_name ne "";
keep employee_name division subdivision department group job_role
	direct_manager indirect_manager1 indirect_manager2 indirect_manager3 indirect_manager4 salary profit;
run;

/*Print the top 5*/
proc sql outobs= 5;
create table orion.top5_sellers as
	select *,
		input(salary, comma12.2) *0.05 as bonus
	from
		(
		select employee_name,
		division,
		subdivision,
		department,
		group,
		job_role,
		direct_manager,
		indirect_manager1,
		indirect_manager2,
		indirect_manager3,
		indirect_manager4,
		sum(profit) as total_profit,
		max(salary) as salary
		from fourth_report
		group by employee_name,
		division,
		subdivision,
		department,
		group,
		job_role,
		direct_manager,
		indirect_manager1,
		indirect_manager2,
		indirect_manager3,
		indirect_manager4
		)
		order by total_profit desc;
run;

***********Report Generation***********;
ods pdf file="Employee_report.pdf" style=journal;
footnote "Session started: &SYSDATE9 &SYSTIME | User: &SYSUSERID";

title1 "Top 5 sellers";

proc report data=orion.top5_sellers nowd;
    columns employee_name division subdivision department
		group job_role direct_manager indirect_manager1
		indirect_manager2 indirect_manager3 indirect_manager4 total_profit salary bonus;
    define employee_name / display "Employee Name";
	define division / display "Division";
	define subdivision / display "Sub Division";
	define Department / display "Department";
	define group / display "Group";
	define job_role / display "Job Role";
	define direct_manager / display "Direct Manager";
	define indirect_manager1 / display "Indirect Manager tier1";
	define indirect_manager2 / display "Indirect Manager tier2";
	define indirect_manager3 / display "Indirect Manager tier3";
	define indirect_manager4 / display "Indirect Manager tier4";
	define total_profit / display "Total Profit";
	define salary / display "Salary";
	define bonus / display "Bonus";
run;

ods pdf close;
