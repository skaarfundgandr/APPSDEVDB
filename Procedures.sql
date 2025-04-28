BEGIN TRANSACTION [procedures];

CREATE PROCEDURE [productPurchaseHistory]
	@productName NVARCHAR(50)
AS
BEGIN
	SELECT [Amount], [Date]
	FROM purchaseHistory
	WHERE @productName = [Product Name]
END;

CREATE PROCEDURE [kioskPurchaseHistory]
	@kioskID BIGINT
AS
BEGIN
	SELECT [Amount], [Date]
	FROM view_purchaseHistory
	WHERE @kioskID = Kiosk
END;

CREATE PROCEDURE [reseedAll] AS
BEGIN
	sp_msforeachtable @command1 = 'DBCC CHECKIDENT(''?'', RESEED, 0)'
END;

CREATE PROCEDURE [RESET_TABLES] AS
BEGIN
	sp_msforeachtable @command1 = 'DELETE FROM ?'
END;

CREATE PROCEDURE [purchaseProduct]
	@productName NVARCHAR(50), @currUser NVARCHAR(50),
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
		INSERT INTO sales (amount, [date])
		VALUES
		(@amount, GETDATE())

		@salesID = CAST(IDENT_CURRENT('sales') AS BIGINT)
		@kioskID = getKioskID(@currUser)

		IF @kioskID IS NULL
		BEGIN
			RAISERROR('Invalid username!', 10, 1)
			ROLLBACK
			RETURN
		END

		INSERT INTO salesDetails (inventoryID, salesID, kioskID)
		VALUES
		(@invID, @salesID, @kioskID)

		UPDATE inventory
		SET quantity -= @amount
		WHERE inventoryID = @invID

		IF @@RowCount > 1
		BEGIN
			RAISERROR('Multiple rows updated rolling back changes...' 15, 1)
			ROLLBACK
			RETURN
		END
	COMMIT
END;

CREATE PROCEDURE [restockProduct]
	@productName NVARCHAR(50),
	@amount INT
AS
BEGIN
	DECLARE @productID BIGINT, @invID BIGINT

	SELECT @invID = [inventory ID]
	FROM view_invProducts
	WHERE [Product Name] = @productName

	@productID = getProductID(@productName)

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
		INSERT INTO restockHistory (inventoryID, amount, [dateTime])
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
	COMMIT
END;

COMMIT;