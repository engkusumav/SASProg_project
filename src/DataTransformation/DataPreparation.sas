/*-------------------------------------*/
/*			Data Preparation		   */
/*-------------------------------------*/

/* Join table between order left join to the product */
proc sql;
	create table work.order_product_joined (compress = yes) as
	select o.*,
		p.product_id, p.product_name,
		p.product_group, p.product_category,
		p.product_line, p.supplier_country, 
		p.supplier_name, p.supplier_id
	from orion.orders_structured as o
	left join orion.product_structured as p
	on o.product_id = p.product_id;
run;


/* Validate data for all fields */
data orion.orders_product_incorrect orion.orders_product_structured(drop= reason);
    set work.order_product_joined;

    length reason $500;

    /* Missing values */
    if missing(order_date) then
        reason = catx('; ', reason, 'Missing order_date');

    if missing(customer_id) then
        reason = catx('; ', reason, 'Missing customer_id');

    if missing(employee_id) then
        reason = catx('; ', reason, 'Missing employee_id');

	if missing(product_id) then
        reason = catx('; ', reason, 'Missing product_id');

	if missing(product_name) then
        reason = catx('; ', reason, 'Missing product_name');

	if missing(product_group) then
        reason = catx('; ', reason, 'Missing product_group');

	if missing(product_category) then
        reason = catx('; ', reason, 'Missing product_category');

	if missing(product_line) then
        reason = catx('; ', reason, 'Missing product_line');

	if missing(supplier_name) then
        reason = catx('; ', reason, 'Missing supplier_name');

	if missing(supplier_id) then
        reason = catx('; ', reason, 'Missing supplier_id');
	
	if missing(supplier_country) then
    	reason = catx('; ', reason, 'Missing supplier_country');

	if missing(order_date) then
        reason = catx('; ', reason, 'Missing order_date');

	if missing(delivery_date) then
        reason = catx('; ', reason, 'Missing delivery_date');

    /* Date logic */
    if not missing(order_date) and not missing(delivery_date) then do;
        if input(order_date, date9.) > input(delivery_date, date9.) then
            reason = catx('; ', reason,
                          'Order date is after delivery date');
    end;

    /* Other checks */
    if upcase(customer_gender) not in ('M','F') then
        reason = catx('; ', reason, 'Invalid customer_gender');

    if order_type not in (1,2,3) then
        reason = catx('; ', reason, 'Invalid order_type');

    if (lengthn(strip(supplier_country)) > 2 or lengthn(strip(customer_country)) > 2) then
        reason = catx('; ', reason, 'Country code too long');

    if reason ne '' then
        output orion.orders_product_incorrect;
    else
        output orion.orders_product_structured;
run;

/*Finalized table */
proc sql;
	create table orion.order_product_final (compress = yes) as
	select order_id,
		customer_id,
		strip(put(employee_id, 20.)) as employee_id,
		case when order_type =1 then "Retail"
			when order_type=2 then "Catalog"
			when order_type=3 then "Internet"
		end as order_type,
		customer_country,
		customer_gender,
		customer_name,
		customer_type,
		input(order_date, date9.) as order_date,
		input(delivery_date, date9.) as delivery_date,
		input(customer_birthdate, date9.) as customer_birthdate,
		input(costprice_per_unit, best.) as costprice_per_unit,
		input(total_retail_price, best.) as total_retail_price,
		input(product_quantity, best.) as product_quantity,
		input(product_id, best.) as product_id,
		product_name format= $20. as product_name,
		product_group format= $20. as product_group,
		product_category format= $20. as product_category,
		product_line format= $20. as product_line,
		supplier_country format = $20. as supplier_country,
		input(supplier_id, best.) as supplier_id,
		supplier_name format=$20.,
		intck('year', input(customer_birthdate, date9.), today(), 'C') as age,
		case when calculated age between 15 and 30 then "15-30 years old"
    		when calculated age between 31 and 45 then "31-45 years old"
    		when calculated age between 46 and 60 then "46-60 years old"
    		when calculated age between 61 and 75 then "61-75 years old"
    		when calculated age between 76 and 90 then "76-90 years old"
   			else "Other"
			end as age_group,
		case when index(compress(lowcase(customer_type)), "lowactivity") > 0 then "Low Activity"
			when index(compress(lowcase(customer_type)), "mediumactivity") > 0 then "Medium Activity"
			when index(compress(lowcase(customer_type)), "highactivity") > 0 then "High Activity"
			else "Not Available"
		end as customer_activity,
		case when index(compress(customer_type), "OrionClubGold") > 0 then "Orion Club Gold"
			when index(compress(customer_type), "OrionClub") > 0 then "Orion Club"
			when index(compress(customer_type), "Internet/CatalogCustomers") > 0 then "Internet/Catalog Customers"
			else "error"
		end as customer_type_group,
		calculated total_retail_price - (calculated costprice_per_unit * calculated product_quantity) as profit
	from orion.orders_product_structured
	order by order_id, product_id,
	customer_id,
	order_date,
	product_quantity,
	total_retail_price
;
run;

/*Get employee information */
proc sql;
	create table work.order_product_emp (compress = yes) as
	select o.*,
		p.employee_name,
		p.first_manager,
		p.second_manager,
		p.third_manager,
		p.fourth_manager,
		p.fifth_manager,
		p.division,
		p.subdivision,
		p.department,
		p.group,
		p.job_role,
		p.salary
	from orion.order_product_final as o
	left join orion.org_structured as p
	on o.employee_id = p.employee_id;
run;

/*Self join for manager information */
proc sql;
    create table orion.order_product_emp as		
    select 
        o.*,
        a.employee_name as direct_manager,
        b.employee_name as indirect_manager1,
        c.employee_name as indirect_manager2,
        d.employee_name as indirect_manager3,
        e.employee_name as indirect_manager4

    from work.order_product_emp as o

    left join orion.org_structured as a
        on o.first_manager = a.employee_id

    left join orion.org_structured as b
        on o.second_manager = b.employee_id

    left join orion.org_structured as c
        on o.third_manager = c.employee_id

    left join orion.org_structured as d
        on o.fourth_manager = d.employee_id

    left join orion.org_structured as e
        on o.fifth_manager = e.employee_id;

run;


/*Summarize data */
proc contents data=orion.order_product_final;
run;

proc contents data=orion.order_product_emp;
run;
