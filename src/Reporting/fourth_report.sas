****Fourth report*****;

data fourth_report;
set orion.order_product_emp;
if employee_name ne "";
keep employee_name division subdivision department group job_role
	direct_manager indirect_manager1 indirect_manager2 indirect_manager3 indirect_manager4 salary profit;
run;


proc sql outobs= 5;
create table top5_sellers as
select *,
input(salary, comma12.2) *0.05 as bonus
from fourth_report
group by employee_name
order by profit desc;
run