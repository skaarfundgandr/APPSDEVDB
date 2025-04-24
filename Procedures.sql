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
	DECLARE @salesID, @kioskID, @invID BIGINT
	SELECT @invID = [inventory ID]
	FROM view_invProducts
	WHERE [Product Name] = @productName

	IF @invID IS NULL
	BEGIN
		RAISERROR('Invalid product name', 5, 1)
		RETURN
	END

	INSERT INTO sales (amount, [date])
	VALUES
	(@amount, GETDATE())

	@salesID = CAST(IDENT_CURRENT('sales') AS BIGINT)
	@kioskID = getKioskID(@currUser)

	IF @kioskID IS NULL
	BEGIN
		RAISERROR('Invalid username!', 10, 1)
		RETURN
	END

	INSERT INTO salesDetails (inventoryID, salesID, kioskID)
	VALUES
	(@invID, @salesID, @kioskID)

	UPDATE inventory
	SET quantity -= @amount
	WHERE inventoryID = @invID
END;
COMMIT;