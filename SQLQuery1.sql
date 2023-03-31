-- checking my table.
select * from Ecommerce_Data

-- I used a sample of the distinct funtion here to check if there are null values in any column.
-- it's important to note that this distinct function was applied in every column but I dont want to make the code long.
 select distinct(Hour)
 from Ecommerce_Data

 -- now its time for us to select columns I need.
 -- Unfortunately, column_1 was not given a column name. the data is from Absentdata.com site.
 -- so I need to remove the column
 select InvoiceNo, StockCode, Description, Quantity,
 UnitPrice, CustomerID, Country, Date,Hour
 from Ecommerce_Data
 
  -- if we look at the Date column, its in a datetime format. the time is not relevant because they are all 00:00:00.
  -- we could keep the date simple by making it only date. using convert(date, column)
  select InvoiceNo, StockCode, Description, Quantity, 
  UnitPrice, CustomerID, Country, convert(date,  Date) as Purchase_Date,Hour
  from Ecommerce_Data

  -- this is an Ecommerce industry, but there is no column for revenue. 
  -- well, we have a column for Quality, and Unit price.
  -- Multiplying values of each columns will give a revenue column
  select InvoiceNo, StockCode, Description, Quantity, 
  UnitPrice, CustomerID, Country, convert(date,  Date) as Purchase_Date,Hour,
 format((Quantity * UnitPrice),'c')as Revenue
  from Ecommerce_Data

  -- lets explore this data more
 -- which country brings the highest revenue
 go
 With Clean_Ecommerce as (select InvoiceNo, StockCode, Description, Quantity, 
  UnitPrice, CustomerID, Country, convert(date,  Date) as Purchase_Date,Hour,
  (Quantity * UnitPrice) as Revenue
  from Ecommerce_Data)

  select country, sum(Revenue) as Revenue
  from Clean_Ecommerce
  group by country
  order by Revenue desc

  -- we can see with this that the United kindom brings more Revenue

_-- I want to the particular customerID and InvoiceNo of client, that has given the highest revenue in this data set.
 go
 With Clean_Ecommerce as (select InvoiceNo, StockCode, Description, Quantity, 
      UnitPrice, CustomerID, Country, convert(date,  Date) as Purchase_Date,Hour,
      (Quantity * UnitPrice) as Revenue
       from Ecommerce_Data),
Rank_Table as (select country,CustomerID, InvoiceNo, Revenue, 
     RANK() Over(Partition by country
     order by Revenue desc) as Rank
     from Clean_Ecommerce
     group by country,CustomerID, InvoiceNo, Revenue), 
-- I found out there were duplicates for revenue with different invoice number for same country.
-- countries like UK, Sweden and multa.
-- I ranked the data below.

Best_with_multiple_values as 
     (select * from Rank_Table
	 where Rank = 1),

-- I used Row number to find the duplicates
 Rownum_column_to_find_duplicate as (select  *, 
 ROW_NUMBER() over (partition by country order by country) as Rownum
 from Best_with_multiple_values)

-- here, I filtered the duplicates to get their unique customer Id and other details.
select country,CustomerID, InvoiceNo, format(Revenue,'c') as Revenue
   from Rownum_column_to_find_duplicate
   where Rownum != 2
   order by Revenue desc;

     
-- The Last time I looked at our Data, I found out that some values in quantity have negetive values.
-- I feel some customers collected Items on credit.
-- the company will like to reach out to these individuals to give them a gentle reminder on their debt.
-- lets get them.

select * from Ecommerce_Data
where Quantity < 0;

-- lets display just their customer ID, invoicenumber,country, description,Quantity, UnitPrice, date of purchase, and  and the total amount they are owing as revenue.
  select  CustomerID,InvoiceNo,Country, Description, Quantity, 
  UnitPrice, convert(date,  Date) as Purchase_Date,
  (Quantity * UnitPrice) as Revenue
  from Ecommerce_Data
  where Quantity < 0
  order by country;

  go
  -- Maybe we want to know the Top five countries owing
  with country_owing_more as (select  CustomerID,InvoiceNo,Country, Description, Quantity, 
  UnitPrice, convert(date,  Date) as Purchase_Date,
  (Quantity * UnitPrice) as Revenue
  from Ecommerce_Data
  where Quantity < 0)

  select Top (5) country, sum(Revenue) as Total_owing_revenue
  from country_owing_more
  group by country
  order by Total_owing_revenue;
  
  
 -- Lets work with date.
-- I will like to know days of the week, month and year of highest purchase.
 with date_related_revenue as (select convert(date, Date) as dates, (Quantity * UnitPrice) as Revenue 
from Ecommerce_Data)

select Datename(weekday,dates) as days_week, datename(MONTH,dates) as months,
 YEAR(dates) as years, Revenue
 from date_related_revenue;
go
 -- for Month with highest revenue irrespective of the year.
 with date_related_revenue as (select convert(date, Date) as dates,
  (Quantity * UnitPrice) as Revenue 
from Ecommerce_Data)

select datename(MONTH,dates) as months,
 format(sum(Revenue),'c') as Revenue
 from date_related_revenue
 group by datename(MONTH,dates)
 order by Revenue asc;
 go
 -- For Days of the week
  with date_related_revenue as (select convert(date, Date) as dates,
  (Quantity * UnitPrice) as Revenue 
from Ecommerce_Data)

select datename(WEEKDAY,dates) as days_week,
 format(sum(Revenue),'c') as Revenue
 from date_related_revenue
 group by datename(WEEKDAY,dates)
 order by Revenue desc;

 -- for Year
  with date_related_revenue as (select convert(date, Date) as dates,
  (Quantity * UnitPrice) as Revenue 
from Ecommerce_Data)

select YEAR(dates) as Years,
 format(sum(Revenue),'c') as Revenue
 from date_related_revenue
 group by Year(dates)
 order by Revenue desc;