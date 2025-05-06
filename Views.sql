USE staging;
GO;
BEGIN TRANSACTION creation_of_views;
GO;

CREATE VIEW view_purchaseHistory AS
	SELECT
		kiosks.kioskID AS [Kiosk],
		prod.productName AS [Product Name],
		sales.amount AS [Amount],
		sales.[date] AS [Date]
	FROM salesDetails
	JOIN kiosks ON salesDetails.kioskID = kiosks.kioskID
	JOIN sales ON salesDetails.salesID = sales.salesID
	JOIN inventory AS inv ON salesDetails.inventoryID = inv.inventoryID
	JOIN products AS prod ON inv.productID = prod.productID;
GO;

CREATE VIEW view_invProducts AS
	SELECT
		inv.inventoryID AS [Inventory ID],
		prod.productName AS [Product Name],
		prod.productDesc AS [Description],
		prod.productCategory AS [Category],
		prod.productPrice AS [Price],
		inv.quantity AS [Quantity],
		inv.units AS [Units],
		inv.latestRestock AS [Last Restock]
	FROM inventory AS inv
	JOIN products AS prod ON inv.productID = prod.productID;
GO;

CREATE VIEW view_restockHistory AS
	SELECT
		prod.productName AS [Product Name],
		restock.amount AS [Amount],
		restock.[date] AS [Date]
	FROM salesDetails
	JOIN inventory AS inv ON salesDetails.inventoryID = inv.inventoryID
	JOIN restockHistory AS restock ON restock.inventoryID = inv.inventoryID
	JOIN products AS prod ON inv.productID = prod.productID;
GO;

COMMIT TRANSACTION creation_of_views;
GO;