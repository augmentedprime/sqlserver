--Set BIT to 0 to check for symbols, set BIT to 1 to delete them (DEV ONLY)
--Find/Replace TRMTC with your exchange code

DECLARE @willDelete		BIT = 0

/*** SCHDETLB ****************************************************************************************/

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[QA]
	WHERE [EXCHANGE_CODE] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[QA]
WHERE [EXCHANGE_CODE] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[TREE_QA]
    WHERE [exchange_code] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[TREE_QA]
WHERE [exchange_code] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[IM_QA]
	WHERE [exchangeCode] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[IM_QA]
WHERE [exchangeCode] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[PROD]
	WHERE [EXCHANGE_CODE] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[PROD]
WHERE [EXCHANGE_CODE] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[TREE_PROD]
    WHERE [exchange_code] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[TREE_PROD]
WHERE [exchange_code] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE [DSPerms].[dbo].[IM_PROD]
	WHERE [exchangeCode] IN ('TRMTC')
END

SELECT * FROM [DSPerms].[dbo].[IM_PROD]
WHERE [exchangeCode] IN ('TRMTC')

/*** PERMS **************************************************************************************************************/
-- SCHTSQLA
IF @willDelete = 1
BEGIN
	DELETE SCHTSQLA.[MVProdPerm2].[dbo].[st_tree]
    WHERE [exchange_code] IN ('TRMTC')
END
                       
SELECT * FROM SCHTSQLA.[MVProdPerm2].[dbo].[st_tree] WITH (NOLOCK)
WHERE [EXCHANGE_CODE] IN ('TRMTC')

IF @willDelete = 1
BEGIN
	DELETE SCHTSQLA.[MVProdPerm2].[dbo].[SYMBOL]
    WHERE [EXCHANGE_CODE] IN ('TRMTC')
END

SELECT * FROM SCHTSQLA.[MVProdPerm2].[dbo].[SYMBOL] WITH (NOLOCK)
WHERE [EXCHANGE_CODE] IN ('TRMTC')


IF @willDelete = 1
BEGIN
	DELETE SCHTSQLA.[mvprodperm2].[dbo].[instrument_metadata]
	WHERE [exchangeCode] IN ('TRMTC') AND instrumentType = 'SF'
END

SELECT * FROM SCHTSQLA.[mvprodperm2].[dbo].[instrument_metadata]
WHERE [exchangeCode] IN ('TRMTC') AND instrumentType = 'SF'
