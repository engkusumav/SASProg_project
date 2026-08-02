# myproj — Product Sales Analysis (SAS)

A SAS data pipeline that ingests raw sales, organisation, and product data, transforms and validates it, and generates a product frequency report in PDF.

---

## Project Structure

```
myproj/
├── src/
│   ├── CreateSASTable/
│   │   └── DataAccess.sas        # Import raw source files into SAS library
│   ├── DataTransformation/
│   │   ├── CleanExcelFile.sas       # Parse nested JSON fields in orders and org tables
│   │   ├── CleanTXTFile.sas         # Parse nested JSON fields in product and supplier table
│   │   ├── DataExploration.sas      # Data quality checks (missing, outliers, duplicates)
│   │   └── DataPreparation.sas      # Join, validate, enrich, and finalise tables
│   └── Reporting/
│       ├── Country_report.sas         # Filtered order report by country and view type
│       ├── Employee_report.sas        # Top 5 sellers employee with their managers information
│       ├── Order_report.sas           # Order detail by product category
│       └── Product_report.sas         # Product frequency within each by group
└── report_output/  
    └── product_report.pdf           # Final PDF report
```

---

## Pipeline Overview

### 1. Create SAS Tables (`CreateSASTable/`)
Imports three raw source files into the `orion` library:
- `orders.xlsx` → `orion.orders`
- `organization.csv` → `orion.org`
- `products.txt` (tab-delimited) → `orion.product`

### 2. Data Transformation (`DataTransformation/`)

**CleanExcelFile.sas**
- Parses nested JSON-like strings in `order_details` column → extracts `product_id`, `product_quantity`, `costprice_per_unit`, `total_retail_price`
- Parses `job` and `manager_hierarchy` columns in org table → extracts `division`, `subdivision`, `department`, `group`, `job_role`, and up to 5 manager levels

**CleanTXTFile.sas**
- Parses `product` column → extracts `product_name`, `product_group`, `product_category`, `product_line`, `product_id`
- Parses `supplier` column → extracts `supplier_name`, `supplier_country`, `supplier_id`

**DataExploration.sas**
- Runs quality checks: missing values, descriptive statistics, distinct character values, duplicates, and data types

**DataPreparation.sas**
- Joins orders to product table on `product_id`
- Validates records — flags rows with missing fields, invalid dates, invalid gender/order type, country codes too long → splits into `orion.orders_product_incorrect` and `orion.orders_product_structured`
- Finalises table with correct data types, derived fields (`age`, `age_group`, `customer_activity`, `customer_type_group`, `profit`)
- Enriches with employee and manager information via self-joins on `orion.org_structured`

### 3. Reporting (`Reporting/`)
Runs PROC SQL aggregations and generates a PDF report (`product_report.pdf`) using ODS PDF covering:
- Most frequently purchased product line overall
- Top 10 most frequently purchased products
- Most frequent product line by customer country
- Most frequent product line by order type
- Most frequent product line by customer age group
- Most frequent product line by customer type
- Most frequent product line by customer activity
- Most frequent product line by supplier name
- Most frequent product line by supplier country

---

## How to Run

1. Update the `libname` path in `DataAccess.sas` to point to your SAS library
2. Update source file paths to match your environment
3. Run scripts in order:
   1. `CreateSASTable/DataAccess.sas`
   2. `DataTransformation/CleanExcelFile.sas`
   3. `DataTransformation/CleanTXTFile.sas`
   4. `DataTransformation/DataExploration.sas` *(optional — for QA)*
   5. `DataTransformation/DataPreparation.sas`
   6. `Reporting/Country_report.sas` 
   7. `Reporting/Employee_report.sas` 
   8. `Reporting/Order_report.sas` 
   9. `Reporting/Product_Report.sas` 

---

## Requirements

- SAS 9.4 or SAS Viya
- Source files: `orders.xlsx`, `organization.csv`, `products.txt`, `product_level.xlsx`
- Write access to the `orion` library path
