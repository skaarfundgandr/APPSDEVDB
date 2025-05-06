USE staging;
GO
BEGIN TRANSACTION [procedures];
GO

CREATE PROCEDURE [productPurchaseHistory]
	@productName NVARCHAR(50)
AS
BEGIN
	SELECT [Amount], [Date]
	FROM purchaseHistory
	WHERE @productName = [Product Name]
END;
GO

CREATE PROCEDURE [kioskPurchaseHistory]
	@kioskID BIGINT
AS
BEGIN
	SELECT [Amount], [Date]
	FROM view_purchaseHistory
	WHERE @kioskID = Kiosk
END;
GO

CREATE PROCEDURE [reseedAll] AS
BEGIN
	EXEC sp_msforeachtable @command1 = 'DBCC CHECKIDENT(''?'', RESEED, 0)'
END;
GO
-- WARN: DESTRUCTIVE PROCEDURE USE WITH CAUTION!!
CREATE PROCEDURE [RESET_TABLES] AS
BEGIN
	EXEC sp_msforeachtable @command1 = 'DELETE FROM ?'
END;
GO

CREATE PROCEDURE [purchaseProduct]
	@productName NVARCHAR(50),
	@amount INT
AS
BEGIN
	DECLARE @salesID BIGINT, @kioskID BIGINT, @invID BIGINT
	SELECT @invID = [inventory ID]
	FROM view_invProducts
	WHERE [Product Name] = @productName

	IF @invID IS NULL
	BEGIN
		RAISERROR('Invalid product name', 5, 1)
		RETURN
	END

	BEGIN TRANSACTION purchase_product
		DECLARE @currUser BIGINT
		INSERT INTO sales (amount, [date])
		VALUES
		(@amount, GETDATE())

		SET @salesID = CAST(IDENT_CURRENT('sales') AS BIGINT)
		SET @kioskID = dbo.getKioskID(@currUser)

		INSERT INTO salesDetails (inventoryID, salesID, kioskID)
		VALUES
		(@invID, @salesID, @kioskID)

		UPDATE dbo.inventory
		SET quantity -= @amount
		WHERE inventoryID = @invID;

		IF @@RowCount > 1
		BEGIN
			RAISERROR('Multiple rows updated rolling back changes...', 15, 1)
			ROLLBACK
			RETURN
		END
	COMMIT TRANSACTION purchase_product
END;
GO

CREATE PROCEDURE [restockProduct]
	@productName NVARCHAR(50),
	@amount INT
AS
BEGIN
	DECLARE @productID BIGINT, @invID BIGINT

	SELECT @invID = [inventory ID]
	FROM view_invProducts
	WHERE [Product Name] = @productName

	SET @productID = dbo.getProductID(@productName)

	IF @productID IS NULL
	BEGIN
		RAISERROR('Invalid product!', 10, 1)
		RETURN
	END

	IF @invID IS NULL
	BEGIN
		RAISERROR('Product not found in inventory!', 10, 1)
		RETURN
	END

	BEGIN TRANSACTION restock_product
		INSERT INTO restockHistory (inventoryID, amount, [date])
		VALUES
		(@invID, @amount, GETDATE())

		UPDATE inventory
		SET quantity += @amount
		WHERE productID = @productID

		IF @@RowCount > 1
		BEGIN
			RAISERROR('Multiple rows affected rolling back changes...', 13, 1)
			ROLLBACK
			RETURN
		END
	COMMIT TRANSACTION restock_product
END;
GO

CREATE PROCEDURE [addProductToInv]
	@productName NVARCHAR(50)
AS
BEGIN
	DECLARE @prodID BIGINT

	SET @prodID = dbo.getProductID(@productName)

	IF @prodID IS NULL
	BEGIN
		RAISERROR('product not found in inventory', 10, 1)
		RETURN
	END

	BEGIN TRANSACTION addProduct
	BEGIN TRY
		INSERT INTO inventory (productID, quantity, latestRestock)
		VALUES
		(@prodID, 0, GETDATE())
		COMMIT TRANSACTION addProduct
	END TRY
	BEGIN CATCH
		RAISERROR('Error adding product to inventory', 10, 1)
		ROLLBACK TRANSACTION addProduct
	END CATCH
END;
GO

COMMIT TRANSACTION [procedures];
GO