/*-------------------------------------*/
/* 		     Product Report 		   */
/*-------------------------------------*/

*What is the most frequently purchased product line?;
proc sql;
	create table orion.frequent_product_line (compress = yes) as
	select product_line, sum(product_quantity) as frequency
	from orion.order_product_final
	group by product_line
	order by frequency desc;
run;

*What are the ten most frequently purchased products?;
proc sql outobs=10;
	create table orion.frequent_top_10 as
	select product_name, product_line, sum(product_quantity) as frequency
	from orion.order_product_final
	group by product_name, product_line
	order by frequency desc;
run;

*What is the most frequently purchased product line by customer country?;
proc sql;
    create table work.frequent_country (compress=yes) as
    select customer_country,
           product_line,
           sum(product_quantity) as frequency
    from orion.order_product_final
    group by customer_country, product_line;
quit;

proc sql;
    create table orion.frequent_country_final (compress=yes) as
    select a.*
    from work.frequent_country as a
    where frequency =
          (select max(b.frequency)
           from work.frequent_country as b
           where a.customer_country = b.customer_country)
    order by customer_country, frequency desc;
quit;

*What is the most frequently purchased product line by order type?;
proc sql;
    create table orion.frequent_order_type as
    select *
    from (
        select order_type,
               product_line,
               sum(product_quantity) as frequency
        from orion.order_product_final
        group by order_type, product_line
    )
    group by order_type
    having frequency = max(frequency)
    order by order_type;
quit;

*What is the most frequently purchased product line by customer age group? ;
proc sql;
    create table orion.most_frequent_age_group as
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
    create table orion.most_frequent_customer_type as
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
    create table orion.most_frequent_cust_activity as
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
    create table orion.most_frequent_supplier_name as
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
    create table orion.most_frequent_supplier_country as
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

***********Report Generation***********;
ods pdf file="/home/student/casuser/product_report.pdf" style=journal;
footnote "Session started: &SYSDATE9 &SYSTIME | User: &SYSUSERID";

title1 "Most frequently purchased product line";

proc report data=orion.frequent_product_line nowd;
    columns product_line frequency;
    define product_line / display "Product Line";
	define frequency / display "Frequency";
run;

title1 "Top 10 most frequently purchased product";

proc report data=orion.frequent_top_10 nowd;
    columns product_name product_line frequency;
    define product_name / display "Product Name";
	define product_line / display "Product Line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by customer country";

proc report data=orion.frequent_country_final nowd;
    columns customer_country product_line frequency;
    define customer_country / display "Customer Country";
	define product_line / display "Product line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by order type";

proc report data=orion.frequent_order_type nowd;
    columns order_type product_line frequency;
    define order_type / display "Order Type";
	define product_line / display "Product line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by customer age group";

proc report data=orion.most_frequent_age_group nowd;
    columns age_group product_line frequency;
    define age_group / display "Age Group";
	define product_line / display "Product line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by customer type";

proc report data=orion.most_frequent_customer_type nowd;
    columns customer_type_group product_line frequency;
    define age_group / display "Age Group";
	define product_line / display "Product line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by customer activity";

proc report data=orion.most_frequent_cust_activity nowd;
    columns customer_activity product_line frequency;
    define customer_activity / display "Customer Activity";
	define product_line / display "Product line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by supplier name";

proc report data=orion.most_frequent_supplier_name nowd;
    columns supplier_name product_line frequency;
    define supplier_name / display "Supplier Name";
	define product_line / display "Product Line";
	define frequency / display "Frequency";
run;

title1 "Most frequently purchased product line by supplier country";

proc report data=orion.most_frequent_supplier_country nowd;
    columns supplier_country product_line frequency;
    define supplier_country / display "Supplier Country";
	define product_line / display "Product Line";
	define frequency / display "Frequency";
run;

ods pdf close;

