/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_Schema_Change.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays any schema changed captured in the default trace.
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
--             2016.03.18  SYoung        Created today.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
DECLARE @enable INT; 
SELECT TOP 1 @enable = CONVERT(INT,value_in_use) FROM SYS.CONFIGURATIONS WHERE name = 'DEFAULT trace ENABLED'  

IF @enable = 1 
   BEGIN 
        DECLARE @d1 DATETIME; 
        DECLARE @diff INT; 
        DECLARE @curr_tracefilename VARCHAR(500);  
        DECLARE @base_tracefilename VARCHAR(500);  
        DECLARE @indx INT ; 

        DECLARE @temp_trace TABLE (
                obj_name NVARCHAR(256)
              , obj_id INT
              , [database_name] NVARCHAR(256)
              , start_time DATETIME
              , event_class INT
              , event_subclass INT
              , object_type INT
              , server_name NVARCHAR(256)
              , login_name NVARCHAR(256)
              , [user_name] NVARCHAR(256)
              , application_name NVARCHAR(256)
              , ddl_operation NVARCHAR(40));
        

        SELECT @curr_tracefilename = [path] FROM SYS.TRACES WHERE is_default = 1 ;  
        SET @curr_tracefilename = REVERSE(@curr_tracefilename) 
        SELECT @indx  = PATINDEX('%\%', @curr_tracefilename) 
        SET @curr_tracefilename = REVERSE(@curr_tracefilename) 
        SET @base_tracefilename = LEFT( @curr_tracefilename,LEN(@curr_tracefilename) - @indx) + '\log.trc'; 
        
        INSERT INTO @temp_trace 
        SELECT ObjectName
             , ObjectID
             , DatabaseName
             , StartTime
             , EventClass
             , EventSubClass
             , ObjectType
             , ServerName
             , LoginName
             , NTUserName
             , ApplicationName
             , 'temp' 
          FROM ::FN_TRACE_GETTABLE( @base_tracefilename, default )  
         WHERE EventClass in (46,47,164) and EventSubclass = 0
           AND ObjectID IS NOT NULL
           AND DatabaseName <> 'tempdb'
           AND LoginName NOT IN ('PROD\SVC_SQL_Management_D','PROD\svc_ctm','PROD\MS_DBA_SQPDSrv$','PROD\MS_DBA_SQPDOrg$'); 

        UPDATE @temp_trace SET ddl_operation = 'CREATE' WHERE event_class = 46;
        UPDATE @temp_trace SET ddl_operation = 'DROP' WHERE event_class = 47;
        UPDATE @temp_trace SET ddl_operation = 'ALTER' WHERE event_class = 164; 

        SELECT @d1 = min(start_time) FROM @temp_trace 
        SET @diff= datediff(hh,@d1,getdate())
        SET @diff=@diff/24; 
        
        SELECT @diff AS difference
             , @d1 AS DATE
             , object_type AS obj_type_desc 
             , (DENSE_RANK() OVER(ORDER BY obj_name,object_type ) )%2 AS l1 
             , (DENSE_RANK() OVER(ORDER BY obj_name,object_type,start_time ))%2 AS l2
             , *
          FROM @temp_trace
         WHERE object_type not in (21587) -- don't bother with auto-statistics AS it generates too much noise
         ORDER BY start_time DESC;
END ELSE 
BEGIN  
        SELECT TOP 0 1 AS [difference]
             , 1 AS [date]
             , 1 AS obj_type_desc
             , 1 AS l1
             , 1 AS l2
             , 1 AS obj_name
             , 1 AS obj_id
             , 1 AS [database_name]
             , 1 AS start_time
             , 1 AS event_class
             , 1 AS event_subclass
             , 1 AS object_type
             , 1 AS server_name
             , 1 AS login_name
             , 1 AS [user_name]
             , 1 AS application_name
             , 1 AS ddl_operation  
END  
END TRY  
BEGIN  CATCH  
SELECT -100 AS difference
     , ERROR_NUMBER() AS DATE
     , ERROR_SEVERITY() AS obj_type_desc
     , 1 AS l1, 1 AS l2
     , ERROR_STATE() AS obj_name
     , 1 AS obj_id
     , ERROR_MESSAGE() AS database_name
     , 1 AS start_time, 1 AS event_class, 1 AS event_subclass, 1 AS object_type, 1 AS server_name, 1 AS login_name, 1 AS user_name, 1 AS application_name, 1 AS ddl_operation  
END CATCH