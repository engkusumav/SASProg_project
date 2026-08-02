*****4.1.Create SAS Tables from Source Files *****;

/*Initiate the library */
libname orion "/home/student/casuser";


/*Create SAS tables from the orders, organization and products source files.*/

/*Orders*/
proc import datafile="/home/student/orders.xlsx" dbms=xlsx
	out=orion.orders replace;
	getnames=yes;
run;

/*Organization*/
proc import datafile="/home/student/organization.csv" dbms=csv
	out=orion.org replace;
	guessingrows=max;
	getnames=yes;
run;

/*Product*/
/*Delimited by tab = '09'x */
proc import datafile="/home/student/products.txt" dbms=dlm
	out=orion.product replace;
	delimiter='09'x;
	guessingrows=max;
	getnames=yes;
run;

libname prodlib xlsx "/home/student/product_level.xlsx";







