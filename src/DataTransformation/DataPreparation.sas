*****Data Preparation*****;

/*Fix Order table */

data check;
set orion.orders;
if employee_id = 99999999;
run;

/*Order_ID is a key identifier for orders with some be an employee some not */
proc sql;
create table check (compress = yes) as
select order_id, count(*) as count
from orion.orders
group by order_id
having count > 1;
run;

/*Check missing value */
/*2 missing values for order and delivery date */
data check;
set orion.orders;
if missing(order_date);
run;
