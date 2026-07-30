*****4.3.Reporting*****;

*What is the most frequently purchased product line?;
proc sql;
	create table work.freqent (compress = yes) as
	select product_line, product_quantity as frequency
	from orion.order_product_final
	group by product_line
	order by frequency desc;
run;

*What are the ten most frequently purchased products?;
proc sql;
	create table work.freqent_top_10 (compress = yes) as
	select product_name, product_id, sum(product_quantity) as frequency
	from orion.order_product_final
	group by product_name, product_id
	order by frequency desc;
run;

*What is the most frequently purchased product line by customer country?;
proc sql;
	create table work.freqent_country (compress = yes) as
	select customer_country, product_line, sum(product_quantity) as frequency
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
	select order_type,
	sum(product_quantity) as frequency
	from orion.order_product_final
	group by order_type
	order by frequency desc;
run;


*What is the most frequently purchased product line by customer age group? ;
/*current date*/

proc sql;
    create table work.most_frequent_age_group as
    select *
    from (
        select age_group,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by age_group, product_line
    )
    group by age_group
    having frequency = max(frequency)
    order by age_group;
quit;


*What is the most frequently purchased product line by customer type? ;
proc sql;
    create table work.most_frequent_customer_type as
    select *
    from (
        select customer_type_group,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by customer_type_group, product_line
    )
    group by customer_type_group
    having frequency = max(frequency)
    order by customer_type_group;
quit;


*What is the most frequently purchased product line by customer activity?;
proc sql;
    create table work.most_frequent_cust_activity as
    select *
    from (
        select customer_activity,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by customer_activity, product_line
    )
    group by customer_activity
    having frequency = max(frequency)
    order by customer_activity;
quit;


*What is the most frequently purchased product line by supplier name? ;
proc sql;
    create table work.most_frequent_supplier_name as
    select *
    from (
        select supplier_name,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by supplier_name, product_line
    )
    group by supplier_name
    having frequency = max(frequency)
    order by supplier_name;
quit;


*What is the most frequently purchased product line by supplier country? ;
proc sql;
    create table work.most_frequent_supplier_country as
    select *
    from (
        select supplier_country,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by supplier_country, product_line
    )
    group by supplier_country
    having frequency = max(frequency)
    order by supplier_country;
quit;

