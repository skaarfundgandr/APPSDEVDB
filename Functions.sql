USE staging;
GO;

CREATE FUNCTION dbo.getProductID
(
    @productName NVARCHAR(50)
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @retVal BIGINT
    SELECT @retVal = products.[productID] FROM products
    WHERE productName = @productName

    RETURN @retVal
END;
GO;

CREATE FUNCTION dbo.getKioskID
(
    @username NVARCHAR(50)
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @retVal BIGINT
    SELECT @retVal = kiosks.[kioskID] FROM kiosks
    WHERE username = @username

    RETURN @retVal
END;
GO;
