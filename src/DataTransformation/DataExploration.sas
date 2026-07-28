*****4.2.Data Transformation, Validation, and filtering*****;
/*Change table name for different assessment */
%let table = orion.orders;

/*Check the format of the table */
proc contents data=&table;
run;

/* Check numeric value columns */
proc means data=&table;
run;

/*Check character column values */
proc freq data=&table nlevels;
    tables _character_ / noprint;
run;

/*For a through investigation on strings */
proc freq data=&table nlevels;
	tables _all_;
run;



