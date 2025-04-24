BEGIN TRANSACTION creation_of_functions;

CREATE FUNCTION getProductID
@productName NVARCHAR(50)
RETURNS BIGINT
AS
BEGIN
    DECLARE @retVal BIGINT
    SELECT @retVal = products.[productID] FROM products
    WHERE productName = @productName

    RETURN @retVal
END;

CREATE FUNCTION getKioskID
@username NVARCHAR(50)
RETURNS BIGINT
AS
BEGIN
    DECLARE @retVal BIGINT
    SELECT @retVal = kiosks.[kioskID] FROM kiosks
    WHERE username = @username

    RETURN @retVal
END;