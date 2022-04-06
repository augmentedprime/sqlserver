WITH symbolRownum AS (
	SELECT ROW_NUMBER() OVER(
		PARTITION BY symbol
		ORDER BY symbol
	) rownum,
	Symbol
	FROM vw_symbols
) SELECT *
FROM symbolRownum a
