*****Data Preparation*****;

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
		employee_id,
		order_type,
		customer_country,
		customer_gender,
		customer_name,
		customer_type,
		order_date,
		delivery_date,
		customer_birthdate,
		costprice_per_unit,
		total_retail_price,
		product_quantity,
		product_id,
		product_name,
		product_group,
		product_category,
		product_line,
		supplier_country,
		supplier_id,
		supplier_name
	from orion.orders_product_structured
	order by order_id, product_id,
	customer_id,
	order_date,
	product_quantity,
	total_retail_price
;
run;


