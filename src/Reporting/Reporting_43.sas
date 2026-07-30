*****4.3.Reporting*****;

*What is the most frequently purchased product line?;
proc sql;
	create table work.freqent (compress = yes) as
	select product_line, sum(input(product_quantity, best.)) as frequency
	from orion.order_product_final
	group by product_line
	order by frequency desc;
run;

*What are the ten most frequently purchased products?;
proc sql;
	create table work.freqent_top_10 (compress = yes) as
	select product_name, product_id, sum(input(product_quantity, best.)) as frequency
	from orion.order_product_final
	group by product_name, product_id
	order by frequency desc;
run;

*What is the most frequently purchased product line by customer country?;
proc sql;
	create table work.freqent_country (compress = yes) as
	select customer_country, product_line, sum(input(product_quantity, best.)) as frequency
	from orion.order_product_final
	group by customer_country, product_line
	order by frequency desc;
run;

data work.frequent_country;
set work.frequent_country;
	if first.customer_country;
run;

*What is the most frequently purchased product line by order type?;
proc sql;
	create table work.freqent (compress = yes) as
	select case when order_type =1 then "Retail"
		when order_type= 2 then "Catalog"
		when order_type= 3 then "Internet"
		end as order_type,
	sum(input(product_quantity, best.)) as frequency
	from orion.order_product_final
	group by order_type
	order by frequency desc;
run;


*What is the most frequently purchased product line by customer age group? ;
