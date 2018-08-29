-- Listing 8.11 How to find an idle session with an open transaction

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT es.session_id
     , es.login_name
     , es.[host_name]
     , est.[text]
	   , cn.last_read
     , cn.last_write
     , es.[program_name]
  FROM sys.dm_exec_sessions es
 INNER JOIN sys.dm_tran_session_transactions st	ON es.session_id = st.session_id
 INNER JOIN sys.dm_exec_connections cn ON es.session_id = cn.session_id
 CROSS APPLY sys.dm_exec_sql_text(cn.most_recent_sql_handle) est
  LEFT OUTER JOIN sys.dm_exec_requests er ON st.session_id = er.session_id
   AND er.session_id IS NULL;
