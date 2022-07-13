


;WITH s AS (
	SELECT TOP 100
		creation_time,
		last_execution_time,
		execution_count,
		total_worker_time / 1000 AS CPU,
		CONVERT(MONEY, (total_worker_time)) / (execution_count * 1000) AS [AvgCPUTime],
		qs.total_elapsed_time / 1000 AS TotDuration,
		CONVERT(MONEY, (qs.total_elapsed_time)) / (execution_count * 1000) AS [AvgDur],
		total_logical_reads AS [Reads],
		total_logical_writes AS [Writes],
		total_logical_reads + total_logical_writes AS [AggIO],
		CONVERT(MONEY, (total_logical_reads + total_logical_writes) / (execution_count + 0.0)) AS [AvgIO],
		[sql_handle],
		plan_handle,
		statement_start_offset,
		statement_end_offset,
		plan_generation_num,
		total_physical_reads,
		CONVERT(MONEY, total_physical_reads / (execution_count + 0.0)) AS [AvgIOPhysicalReads],
		CONVERT(MONEY, total_logical_reads / (execution_count + 0.0)) AS [AvgIOLogicalReads],
		CONVERT(MONEY, total_logical_writes / (execution_count + 0.0)) AS [AvgIOLogicalWrites],
		query_hash,
		query_plan_hash,
		total_rows,
		CONVERT(MONEY, total_rows / (execution_count + 0.0)) AS [AvgRows],
		total_dop,
		CONVERT(MONEY, total_dop / (execution_count + 0.0)) AS [AvgDop],
		total_grant_kb,
		CONVERT(MONEY, total_grant_kb / (execution_count + 0.0)) AS [AvgGrantKb],
		total_used_grant_kb,
		CONVERT(MONEY, total_used_grant_kb / (execution_count + 0.0)) AS [AvgUsedGrantKb],
		total_ideal_grant_kb,
		CONVERT(MONEY, total_ideal_grant_kb / (execution_count + 0.0)) AS [AvgIdealGrantKb],
		total_reserved_threads,
		CONVERT(MONEY, total_reserved_threads / (execution_count + 0.0)) AS [AvgReservedThreads],
		total_used_threads,
		CONVERT(MONEY, total_used_threads / (execution_count + 0.0)) AS [AvgUsedThreads]
    FROM sys.dm_exec_query_stats AS qs WITH (READUNCOMMITTED)
    ORDER BY CONVERT(MONEY, (qs.total_elapsed_time)) / (execution_count * 1000) DESC
)
SELECT 
	s.creation_time,
	s.last_execution_time,
	s.execution_count,
	s.CPU,
	s.[AvgCPUTime],
	s.TotDuration,
	s.[AvgDur],
	s.[AvgIOLogicalReads],
	s.[AvgIOLogicalWrites],
	s.[AggIO],
	s.[AvgIO],
	s.[AvgIOPhysicalReads],
	s.plan_generation_num,
	s.[AvgRows],
	s.[AvgDop],
	s.[AvgGrantKb],
	s.[AvgUsedGrantKb],
	s.[AvgIdealGrantKb],
	s.[AvgReservedThreads],
	s.[AvgUsedThreads],
	--st.text as query_text,
	CASE 
		WHEN sql_handle IS NULL THEN ' '
		ELSE SUBSTRING(st.text,
			(s.statement_start_offset + 2) / 2,
			(CASE
				WHEN s.statement_end_offset = -1 THEN
					LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
				ELSE
					s.statement_end_offset
			END - s.statement_start_offset
			) / 2
		)
	END AS query_text,
	DB_NAME(st.dbid) AS database_name,
	OBJECT_SCHEMA_NAME(st.objectid, st.dbid) + '.' + OBJECT_NAME(st.objectid, st.dbid) AS [object_name],
	sp.[query_plan],
	s.[sql_handle],
	s.plan_handle,
	s.query_hash,
	s.query_plan_hash
FROM s
    CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) AS st
    CROSS APPLY sys.dm_exec_query_plan(s.[plan_handle]) AS sp
