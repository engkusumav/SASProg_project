*****Second report*****;

%macro report_2(user_input);

%let compul_var= user_input;
/* Count how many categories the user entered */
%let selected_count=%sysfunc(countw(%superq(user_input),%str(,)));

/* Count how many valid categories were selected */
proc sql noprint;
    select count(distinct product_category)
    into :valid_count
    from orion.order_product_final
    where product_category in (&user_input);
quit;

/*Check if all user input exist if not then warn the user */
%if &valid_count ne &selected_count %then %do;
    %put ERROR: One or more invalid product categories selected.;
	 proc sql noprint;
	    select distinct product_category
	    into :available_options separated by ', '
	    from orion.order_product_final
	    order by product_category;
	quit;

	%put ERROR: Available product categories are: &available_options;

    %return;
%end;

/*If no selection print all, but if yes print the correct result*/
%if selected_count= 0 %then %do;

	data orion.user_inputuct;
	set orion.order_product_final;
		format order_date monyy7. total_retail_price dollar10.2;
		keep product_id order_id customer_name
			total_retail_price order_date product_category;
	run;

%end;

%else %do;

	data orion.user_inputuct;
	set orion.order_product_final;
		format order_date monyy7. total_retail_price dollar10.2;
		keep product_id order_id customer_name
			total_retail_price order_date product_category;
		if product_category in (&user_input);
	run;
%end;

***********Report Generation***********;
ods pdf file="order_report.pdf" style=journal;
footnote "Session started: &SYSDATE9 &SYSTIME | User: &SYSUSERID";

%if %sysfunc(countw(%superq(user_input),%str(,))) = 2 %then %do;
    %let user_input_cleaned=%sysfunc(compress(%superq(user_input),%str(%')));
%let user_input_cleaned=%sysfunc(tranwrd(%superq(user_input_cleaned),%str(,),%str( and )));
    title1 "Order report including &user_input_cleaned.";
%end;
%else %do;
    title1 "Order report including &user_input.";
%end;

proc report data=orion.user_inputuct nowd;
    columns product_id order_id customer_name
	total_retail_price order_date product_category;
    define product_id / display "Product ID";
	define order_id / display "Order ID";
	define customer_name / display "Customer Name";
	define total_retail_price / display "Total Retail Price";
	define order_date / display "Order Date";
	define product_category / display "Product Category";
run;

%mend;

/*Define all product category needed as a string*/
%report_2(user_input= %str('Golf','Outdoors', 'Shoes') );

