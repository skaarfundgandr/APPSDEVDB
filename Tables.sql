USE staging;
GO;
BEGIN TRANSACTION creation_of_tables;
GO;
-- List of products
CREATE TABLE products (
	productID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	productName NVARCHAR(50) NOT NULL,
	productDesc NVARCHAR(50),
	productCategory NVARCHAR(50) NOT NULL,
	productPrice DECIMAL(18, 2) NOT NULL,
	CONSTRAINT [CHK_PRODNAME] UNIQUE(productName),
	CONSTRAINT [CHK_PRODPRICE] CHECK (productPrice >= 0)
);
GO;
-- Products in inventory
CREATE TABLE inventory (
	inventoryID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	productID BIGINT NOT NULL,
	quantity INT NOT NULL,
	units NVARCHAR(50),
	latestRestock DATE,
	CONSTRAINT [FK_INV_productID] FOREIGN KEY (productID) REFERENCES products(productID) ON UPDATE CASCADE,
	CONSTRAINT [CHK_INVQUANTITY] CHECK (quantity >= 0)
);
GO;
-- Restock history of inventory
CREATE TABLE restockHistory (
	restockID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	inventoryID BIGINT NOT NULL,
	amount INT NOT NULL,
	[date] DATE NOT NULL,
	CONSTRAINT [FK_RH_inventoryID] FOREIGN KEY (inventoryID) REFERENCES inventory(inventoryID) ON UPDATE CASCADE,
	CONSTRAINT [CHK_RESTOCK_AMOUNT] CHECK (amount > 0)
);
GO;
-- Products sold within a given date
CREATE TABLE sales (
	salesID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	amount INT NOT NULL,
	[date] DATE NOT NULL,
	CONSTRAINT [CHK_SALES_AMOUNT] CHECK (amount >= 0)
);
CREATE TABLE kiosks (
	kioskID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	username NVARCHAR(50) NOT NULL,
	[password] NVARCHAR(50) NOT NULL,
	CONSTRAINT [CHK_USERNAME] UNIQUE(username)
);
GO;
-- Intermediary table for connecting inventory, sales, and kiosks
CREATE TABLE salesDetails (
	referenceID BIGINT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	inventoryID BIGINT NOT NULL,
	salesID BIGINT NOT NULL,
	kioskID BIGINT NOT NULL,
	CONSTRAINT [FK_SD_inventoryID] FOREIGN KEY (inventoryID) REFERENCES inventory(inventoryID) ON UPDATE CASCADE,
	CONSTRAINT [FK_SD_salesID] FOREIGN KEY (salesID) REFERENCES sales(salesID) ON UPDATE CASCADE,
	CONSTRAINT [FK_SD_kioskID] FOREIGN KEY (kioskID) REFERENCES kiosks(kioskID) ON UPDATE CASCADE
);
GO;

COMMIT TRANSACTION creation_of_tables;