/*
-------------------------------------------------------------------------------------------------
        NAME: DB_Compress_All.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: CREATES DDL STATEMENTS TO COMPRESS TABLES
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET NOCOUNT ON 

DECLARE @TSQL varchar(1000)
      , @schema varchar(128)
      , @tablename varchar(128)
			, @type tinyint
			, @indexname varchar(128)


DECLARE C CURSOR
    FOR SELECT DISTINCT D.name [SchemaName]
             , C.name [TableName]
						 , I.[name] [IndexName]
						 , I.[type]
						 --, I.index_id, A.data_compression_desc
          FROM sys.objects C WITH (NOLOCK) 
         INNER JOIN sys.partitions A WITH (NOLOCK) ON C.[object_id] = A.[object_id]
         INNER JOIN sys.schemas D WITH (NOLOCK) ON C.[schema_id] = D.[schema_id]
         INNER JOIN sys.database_principals E WITH (NOLOCK) ON D.principal_id = E.principal_id
				 INNER JOIN sys.indexes I WITH (NOLOCK) ON A.index_id = I.index_id
				   AND A.object_id = I.object_id
         WHERE 1 = 1
				   AND A.data_compression = 0
           AND C.[type] = 'U'
           AND C.is_ms_shipped = 0
           AND C.[name] NOT LIKE 'MS%'
					 AND I.object_id > 1000
					 AND SCHEMA_NAME(C.schema_id) <> 'SYS' 
         ORDER BY D.name, C.name

OPEN C

FETCH NEXT FROM C INTO @schema, @tablename, @indexname, @type

WHILE @@FETCH_STATUS = 0      
      BEGIN      
      SELECT @TSQL = CASE @type                      
                     WHEN 1 THEN N'ALTER TABLE ['+ @schema +'].['+ @tablename +'] REBUILD WITH (DATA_COMPRESSION = PAGE)' + CHAR(10) +'GO'+ CHAR(10)                     
                     WHEN 0 THEN N'ALTER TABLE ['+ @schema +'].['+ @tablename +'] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)' + CHAR(10) +'GO'+ CHAR(10)                     
                     ELSE N'ALTER INDEX ['+ @indexname +'] ON ['+ @schema +'].['+ @tablename +'] REBUILD WITH (DATA_COMPRESSION = PAGE)' + CHAR(10) +'GO'+ CHAR(10) END      
      
      SELECT @TSQL			

      FETCH NEXT FROM C INTO @schema, @tablename, @indexname, @type
END
CLOSE C
DEALLOCATE C


