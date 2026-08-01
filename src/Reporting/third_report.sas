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

/*if type is not specified then show just compulsory columns*/
%if %length(%superq(type)) = 0 %then %do;
    %let extra_var=&compul_var;
%end;

%if %length(%superq(type)) > 0 and 
    %sysfunc(indexw(CUSTOMER PRODUCT FINANCIAL,%upcase(&type))) = 0 %then %do;

    %put ERROR: Invalid type selected.;
    %put ERROR: Please select from these available types: CUSTOMER PRODUCT FINANCIAL;
    %return;

%end;

/* get the country in the table */
proc sql noprint;
    select distinct quote(trim(customer_country))
    into :available_country separated by ', '
    from orion.order_product_final;
quit;

/* Check the user input if in the available country */
proc sql noprint;
    select count(distinct customer_country)
    into :valid_count
    from orion.order_product_final
    where customer_country in (&input_country);
quit;

/* Count number of countries entered */
%let selected_count=%sysfunc(countw(%superq(input_country),%str(,)));

%if &valid_count ne &selected_count %then %do;
    %put ERROR: Invalid customer country selected.;
    %put ERROR: Please select from these available countries: &available_country;
    %return;
%end;

%if %length(&input_country) = 0 %then %do;
	proc sql;
		create table orion.country_report as
	    select
	        &compul_var
	        %if %length(&extra_var) %then , &extra_var;
	    from orion.order_product_final;
	quit;
%end;

%else %do;
	proc sql;
		create table orion.country_report as
	    select
	        &compul_var
	        %if %length(&extra_var) %then , &extra_var;
	    from orion.order_product_final
		where customer_country in (&input_country);
	quit;
%end;

***********Report Generation***********;
ods pdf file="country_report.pdf" style=journal;
footnote "Session started: &SYSDATE9 &SYSTIME | User: &SYSUSERID";

/*Remove , for reporting purpose */
%let compul_var_clean=%sysfunc(tranwrd(%superq(compul_var),%str(,),%str( )));
%let extra_var_clean=%sysfunc(tranwrd(%superq(extra_var),%str(,),%str( )));

/*Upper case for type */
%let type_upper= %sysfunc(propcase(&type));

%if %sysfunc(countw(%superq(input_country),%str(,))) = 2 %then %do;
    %let user_input_cleaned=%sysfunc(compress(%superq(input_country),%str(%')));
%let user_input_cleaned=%sysfunc(tranwrd(%superq(user_input_cleaned),%str(,),%str( and )));
    title1 "&type_upper Report including &user_input_cleaned.";
%end;
%else %do;
    title1 "&type_upper Report including &user_input.";
%end;

proc report data=orion.country_report nowd;
    columns &compul_var_clean &extra_var_clean;
 	define order_id / display "Order ID";
	define order_date / display "Order Date";
	define delivery_date / display "Delivery Date";
	define order_type / display "Order Type";
	define customer_name / display "Customer Name";
	define profit / display "Profit";
	define customer_country / display "Customer Country";
	define age_group / display "Age Group";
	define customer_type / display "Customer Type";
	define customer_activity / display "Customer Activity";
	define product_line / display "Product Line";
	define product_name / display "Product Name";
	define product_group / display "Product Group";
	define product_category / display "Product Category";
	define total_retail_price / display "Total Retail Price";
	define costprice_per_unit / display "Cost Price Per Unit";
	define product_quantity / display "Product Quantity";
run;

ods pdf close;

%mend;

%third_report( type = product, input_country =%str('AU','US'));

