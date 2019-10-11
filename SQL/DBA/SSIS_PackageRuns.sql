/*-----------------------------------------------------------------------------------------------
        NAME: SSIS_PackageRuns.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays basic information about SSIS package execution
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-----------------------------------------------------------------------------------------------*/
SET NOCOUNT ON
DECLARE @job_name nvarchar(128)

SET @job_name '<JobName, sysname, JobName>' 

SELECT C.[name] [project_name]
     , D.[name] [package_name]
     , D.[package_format_version]
     , B.[executable_name] [step]
     , A.[start_time] [step_start]
     , A.[end_time] [step_end]
     , master.[dbo].[fn_CreateTimeString](A.[execution_duration] / 1000) [duration]
     , CASE A.[execution_result] WHEN 0 THEN 'SUCCESS'
                                 WHEN 1 THEN 'FAILURE'
                                 WHEN 2 THEN 'COMPLETED'
                                 WHEN 3 THEN 'CANCELLED' END [status]                             
     , C.[deployed_by_name] [deployed_by]
     , C.created_time [created]
     , C.last_deployed_time [updated]
  FROM [SSISDB].[internal].[executable_statistics] A
 INNER JOIN [internal].[executables] B ON A.[executable_id] = B.[executable_id]
 INNER JOIN [internal].[projects] C ON B.[project_id] = C.[project_id]
 INNER JOIN [internal].[packages] D ON C.[project_id] = D.[project_id]
   AND B.project_version_lsn = D.project_version_lsn
 WHERE 1 = 1
   AND C.[name] = COALESCE(@job_name, C.[name])
 ORDER BY A.[end_time] DESC
