--Ian P - Deal with scientific notation--
UPDATE Stage
SET [value] = convert(numeric(18,18),convert(real,[Value]))
WHERE [value] LIKE '%E%'