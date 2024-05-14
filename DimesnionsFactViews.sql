--Dim Territory
create view [vw_Dim|Territory]
as
select [TerritoryID], 
	   [Name] [Territory], 
	   [CountryRegionCode], 
	   [Group]
from [sales].[SalesTerritory]



--Dim Ship Method
create view [vw_Dim|ShipMethod]
as
select [ShipMethodID], [Name] [ShipMethod]
from [Purchasing].[ShipMethod]


-- Dim Product
create or alter view [vw_Dim|Product]
as
select p.[ProductID], 
	   p.[Name] [Product],
	   p.StandardCost,
	   p.ListPrice,
	   p.ListPrice - p.StandardCost as Profit,
	   s.[Name] [SubCategory],
	   c.[Name] [Category]
from [Production].[Product] p 
left join [Production].[ProductSubcategory] s
on p.ProductSubcategoryID = s.ProductSubcategoryID
left join [Production].[ProductCategory] c
on s.ProductCategoryID = c.ProductCategoryID


--Dim Status --
-- Recursive CTE --
create or alter view [vw_Dim|Status]
as
with cte
as 
(
select 1 StatusId, [dbo].[ufnGetSalesOrderStatusText](1) [Status]
union all
select StatusId + 1, [dbo].[ufnGetSalesOrderStatusText](StatusId +1) [Status]
from cte
where StatusId < 6
)
select *
from cte



-- Fact Sales Order Details 
create or alter view [vw_Fact|SalesOrderDetails]
as
SELECT od.[SalesOrderID]
      ,od.[SalesOrderDetailID]
      ,od.[ProductID]
	  ,o.[SalesPersonID]
      ,o.[TerritoryID]
      ,o.[ShipMethodID]
	  ,o.[Status] [StatusId]
	  ,CAST (FORMAT(o.[OrderDate],'yyyyMMdd') AS INT) [OrderDate]
	  ,CAST (FORMAT(o.[DueDate],'yyyyMMdd') AS INT) [DueDate]
	  ,CAST (FORMAT(o.[ShipDate],'yyyyMMdd') AS INT) [ShipDate]
      ,od.[UnitPrice]
	  ,od.[OrderQty]
      ,od.[LineTotal]
	  ,o.SubTotal
      ,o.[OnlineOrderFlag]
      ,(od.LineTotal/o.SubTotal)*o.TaxAmt [TaxAmt]
      ,(od.LineTotal/o.SubTotal)*o.[Freight] [Freight]
      ,(od.LineTotal/o.SubTotal)*o.[TotalDue] [TotalDue]
  FROM [Sales].[SalesOrderDetail] od
  inner join [Sales].[SalesOrderHeader] o
  on od.SalesOrderID = o.SalesOrderID

  