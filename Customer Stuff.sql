DECLARE @ALT_EXCHANGE varchar(MAX) = '|' + 
(	
	SELECT (CONCAT(exchangeCode,'|'))
	FROM customer
	FOR XML PATH('')
)

SELECT  sourceID,
    (
    SELECT '|' + exchangeCode
    FROM CustomerFile  cf
    JOIN customer c 
        ON cf.customerName = c.customerName 
    WHERE sourceID = Results.sourceID
    FOR XML PATH('')
    ) AS altExchange
FROM CustomerFile Results
GROUP BY sourceID

SELECT  sourceID,
    (
    SELECT '|' + exchangeCode
    FROM CustomerFile  cf
    JOIN customer c 
        ON cf.customerName = c.customerName 
    WHERE sourceID = Results.sourceID
    FOR XML PATH('')
    ) AS altExchange
FROM CustomerFile Results
GROUP BY sourceID