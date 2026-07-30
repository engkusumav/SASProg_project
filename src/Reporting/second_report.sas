*****Second report*****;

%macro report_2(first_prod, second_prod);

data first_product;
set orion.order_product_final;
	format order_date monyy7. total_retail_price dollar10.2;
	keep product_id order_id customer_name
		total_retail_price order_date product_category;
	if product_category= "&first_prod";
run;

data second_product;
set orion.order_product_final;
	format order_date monyy7. total_retail_price dollar10.2;
	keep product_id order_id customer_name
		total_retail_price order_date product_category;
	if product_category= "&second_prod";
run;

%mend;


%report_2(first_prod= Golf, second_prod= Outdoors );


