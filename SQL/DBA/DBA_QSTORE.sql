SELECT A.query_id
     , COUNT(C.plan_id) plan_count
	 , A.object_id
	 , MAX(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), C.last_execution_time)) local_last_execution_time
	 , MAX(B.query_sql_text) query_text
 FROM sys.query_store_query A
INNER JOIN sys.query_store_query_text B ON A.query_text_id = B.query_text_id
INNER JOIN sys.query_store_plan C ON A.query_id = C.query_id
GROUP BY A.query_id, A.object_id
