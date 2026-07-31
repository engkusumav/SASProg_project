****Third report*****;

%macro third_report(type, input_country);

%let compul_var= order_id,
				order_date,
				delivery_date,
				order_type,
				customer_name,
				profit;
%let cust_var= customer_country,
				age_group,
				customer_type,
				customer_activity;
%let prod_var= product_line,
				product_name,
				product_group,
				product_category;
%let order_var= total_retail_price,
				costprice_per_unit,
				product_quantity;


%if &type = customer %then %let extra_var = &cust_var;
%else %if &type = product %then %let extra_var = &prod_var;
%else %if &type = financial %then %let extra_var = &order_var;

%if %length(&input_country) = 0 %then %do;
	proc sql;
	    select
	        &compul_var
	        %if %length(&extra_var) %then , &extra_var;
	    from orion.order_product_final;
	quit;
%end;

%else %do;
	proc sql;
	    select
	        &compul_var
	        %if %length(&extra_var) %then , &extra_var;
	    from orion.order_product_final
		where customer_country in (&input_country);
	quit;
%end;

%mend;

%third_report( type = customer, input_country =%str('AU','US'));

