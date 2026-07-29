*****Clean Excel file****;

data orion.orders_structured;
set orion.orders;

	/*Remove brackets*/
	lines = compress(order_details, '[]');

	/* Identify different product columns */
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


data work.org_structured;
set orion.org;

	/*Remove brackets*/
	lines = compress(job, '[]');

	/* Identify different org columns*/
	lines= prxchange('s/}\s*,\s*{/|/', -1, lines);

	/* Clean different org columns */
	array new_lines[5] $200 lines_1-lines_5;

	do j  = 1 to 5;
		do i = 1 to 5 while (scan(lines, i, '|') ne '');
			token = scan(lines, i, '|');
			if prxmatch(cats('/"level"\s*:\s*', j, '/'), token) then do;
				new_lines[j] = token;
				leave;
			end;
		end;
	end;

	/*Find id position */
	do i = 1 to 5;
		position = index(new_lines[i], 'id');
	    if position > 0 then do;
			new_lines[i] = substr(new_lines[i], position);
			new_lines[i] = compress(compress(substr(substr(new_lines[i], 4, '"'), 2), '"'), '}]');

		end;
	end;

	division = lines_1;
	subdivision = lines_2;
	department = lines_3;
	group = lines_4;
	job_role = lines_5;

	drop job lines_1 lines_2 lines_3 lines_4 lines_5
		lines j i token position;

run;



data orion.org_structured;
set work.org_structured;

	/*Remove brackets*/
	lines = compress(manager_hierarchy, '[]');

	/* Identify different org columns*/
	lines= prxchange('s/}\s*,\s*{/|/', -1, lines);

	/* Clean different org columns */
	array new_lines[4] $200 lines_1-lines_4;

	do j  = 1 to 4;
		do i = 1 to 4 while (scan(lines, i, '|') ne '');
			token = scan(lines, i, '|');
			if prxmatch(cats('/"level"\s*:\s*', j, '/'), token) then do;
				new_lines[j] = token;
				leave;
			end;
		end;
	end;

	/*Find id position */
	do i = 1 to 4;
		position = index(new_lines[i], 'id');
	    if position > 0 then do;
			new_lines[i] = substr(new_lines[i], position);
			new_lines[i] = compress(compress(substr(substr(new_lines[i], 4, '"'), 2), '"'), '}]');

		end;
	end;

	first_manager= lines_1;
	second_manager= lines_2;
	third_manager= lines_3;
	fourth_manager= lines_4;

	drop manager_hierarchy lines_1 lines_2 lines_3 lines_4 
		lines j i token position;

run;