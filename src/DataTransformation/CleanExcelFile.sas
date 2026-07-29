*****Clean Excel file****;

data orion.orders_structured;
set orion.orders;

/*Remove brackets*/
lines = compress(order_details, '[]');

/* Clean different supplier columns */
array levels[4] $20 _temporary_ ('Product_id' 'Quantity' 'CostPrice_Per_Unit' 'Total_Retail_Price');
array new_lines[8] $200 lines_1-lines_8;

do j  = 1 to 8;
	new_lines[j]= compress(scan(scan(lines, j, ','), 2, ':'), '"}');
end;

product_id= lines_2;
product_quantity= lines_4;
costprice_per_unit= lines_6;
total_retail_price=lines_8;

drop lines_1 lines_3 lines_5 lines_7 
		lines_2 lines_4 lines_6 lines_8
		order_details j lines;

run;