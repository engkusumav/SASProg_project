/*-------------------------------------*/
/* 		Machine Learning Data Split    */
/*-------------------------------------*/

%macro sampling(type);

/* Simple Random Sampling */
%if %upcase(&type)= "SRS" %then %do;
	data work.train work.validation work.test;
		set orion.order_product_final;
		value = ranuni(42);
		if value <=0.6 then output work.train;
		else if value <=0.8 then output work.validation;
		else output work.test;
	run;
%end;

/*Stratified random sampling */
%else %if %upcase(&type)= "STRATIFIED" %then %do;
	%let column_strata = order_type;

		proc sort data=orion.order_product_final
		          out=work.order_strata;
		    by &column_strata;
		run;

		data work.train work.validation work.test;
		    set work.order_strata;
		    by &column_strata;

		    if first.&column_strata then call streaminit(42);

		    value = rand("Uniform");

		    if value <= 0.60 then output work.train;
		    else if value <= 0.80 then output work.validation;
		    else output work.test;

		    drop value;
		run;
%end;

/*Cluster Sampling*/
%else %if %upcase(&type)= "CLUSTER" %then %do;
	/*Cluster Sampling*/
	%let column_cluster = Customer_Country;
	%let value_cluster = US;

	data work.order_cluster;
	    set orion.order_product_final;
	    if &column_cluster = "&value_cluster";
	run;

	data work.train work.validation work.test;
	    set work.order_cluster;
	    value = ranuni(42);

	    if value <= 0.6 then output work.train;
	    else if value <= 0.8 then output work.validation;
	    else output work.test;
	run;
%end;

%else %do;
	%put ERROR: Please input the correct type: SRS, Stratified, or Cluster ;

%end;

%mend;

/*Please select the sampling type here*/
%sampling(type="Stratified")









