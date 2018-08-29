:CONNECT PR
USE DBA_BACKUP
GO
/*-------------------------------------------------------------------------------------------------
        NAME: DBA_sp_t_Modified.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays row count, index size and total table size for a specific file(s). This
              script requires that sp_t procedure already exist on the server.

   PARAMETER: d = data_size
              i = index_size
              r = row_count
              s = total_size
              t = table_name
              o = oldest
              n = newest
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
/*
:CONNECT M1
USE DBA_BACKUP
GO
SET NOCOUNT ON

PRINT N'DECLARE @Tables AS TABLE ([start_time] [datetime] NULL,[server_name] [varchar](128) NULL,[obj_name] [varchar](128) NULL,[database_name] [varchar](128) NULL,[login_name] [varchar](128) NULL,[user_name] [varchar](128) NULL,[ddl_operation] [varchar](128) NULL)'
        
SELECT N'INSERT INTO @Tables ([start_time],[server_name],[obj_name],[database_name],[login_name],[user_name],[ddl_operation]) VALUES ('''+ CAST(start_time AS varchar(25)) +''', '''+ server_name +''','''+ obj_name +''', '''+ database_name +''', '''+ login_name +''','''+ user_name +''','''+ ddl_operation +''');'
  FROM [DBA].[dbo].[SchemaChange]
 WHERE 1 = 1
   AND server_name = 'SERVERNAME\INSTANCENAME' 
   AND [database_name] = 'DBA_BACKUP'
   AND (obj_name LIKE 'ObjectName%' or obj_name LIKE 'Pattern%' )
   AND login_name NOT IN ('DOMAIN\ADAccount')
   AND ddl_operation = 'CREATE'
GO
*/

SET NOCOUNT ON

DECLARE @sp_t TABLE (
       instance_name VARCHAR(40)
     , database_name VARCHAR(40)
     , [type] CHAR(1)
     , [schema_name] VARCHAR(40)
     , table_name VARCHAR(200)
     , create_date DATE
     , row_count BIGINT
     , data_size INT
     , index_size INT
     , total_size INT)

INSERT INTO @sp_t
EXEC sp_t @order = 't';

--[ PASTE RESULT FROM UPPER QUERY BELOW THIS LINE ]
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[ EXECUTE T-SQL IN THIS ENTIRE WINDOW           ]

SELECT B.start_time
     , B.[server_name] [instance_name]
     , B.[database_name]
     , B.login_name
     --, N''+ B.[user_name] +'@domainname.com' [user_name]
     , B.ddl_operation
     --, A.[type]
     --, A.[schema_name]
     , A.table_name
     , A.row_count
     --, A.data_size
     --, A.index_size
     , A.total_size
  FROM @sp_t A
 INNER JOIN @Tables B ON A.table_name = B.obj_name
  WHERE table_name IN ('TableNames')
  ORDER BY start_time
  GO
