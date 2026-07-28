*****4.2.Data Transformation, Validation, and filtering*****;

/* Criteria
1). Missing values (completeness)
2). Descriptive Statistics (mean, max, outliers)
3). Distinct values (character anomaly, etc.)
4). Duplicates (does duplicate logics makes sense)
5). Data types (character,numeric and dates in a correct format)
*/

/*Change table name for different assessment */
%let table = orion.orders;

/*Check the format of the table */
proc contents data=&table;
run;

/* Check numeric value columns */
proc means data=&table nmiss n mean max min;
run;

/*Check character column values */
proc freq data=&table nlevels;
    tables _character_ / noprint;
run;

/*For a through investigation on strings */
proc freq data=&table nlevels;
	tables _all_;
run;



