*****Clean TXT file*****;

DATA clean_txt_file;
set work.product;

/*Remove brackets*/
lines = compress(product, '[');

/* Change , to -- */
lines= prxchange('s/}\s*,\s*{/|/', -1, lines);


/* Fix detail */
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

product_name = lines_1;
product_group = lines_2;
product_category = lines_3;
product_line = lines_4;
product_id = lines_5;

keep product supplier product_name product_group product_category product_line product_id;
		
run;


data work.product;
set work.clean_txt_file;

/*Remove brackets*/
lines = compress(compress(supplier, '['), ']');

lines= prxchange('s/}\s*,\s*{/|/', -1, lines);

array new_lines[3] $200 lines_1-lines_3;
array levels[3] $20 _temporary_ ('Name' 'Country' 'ID');

do j  = 1 to 3;
	do i = 1 to 3 while (scan(lines, i, '|') ne '');
		token = compress(compress(scan(lines, i, '|'), "{"), "}");
		if prxmatch(cats('/"level"\s*:\s*"', levels[j], '"/'), token) then do;
			new_lines[j] = token;
			leave;
		end;
	end;
end;

run;

