/*-----------------------------------------------------------------------------------------------
        NAME: SA_Alert_List.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays details about all the alerts
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    04.14.2019  SYoung        Initial creation.
--            08.20.2019  SYoung        Rename file with prefix (SA = SQL Agent) 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SELECT CAST(GETDATE() AS DATE) [date]
     , @@SERVERNAME [instance_name]
     , A.[name] [alert]
     , A.[enabled]
     , A.[performance_condition]
     , A.[message_id]
     , A.[severity]
     , CASE A.[has_notification] WHEN 1 THEN 'Email' WHEN 2 THEN 'Page' WHEN 3 THEN 'Email/Page' ELSE 'None' END [has_notification]
     , O.[name] [operator]
  FROM [msdb].[dbo].[sysalerts] A
 INNER JOIN [msdb].[dbo].[sysnotifications] N ON A.id = N.alert_id
 INNER JOIN [msdb].[dbo].[sysoperators] O ON N.operator_id = O.id
ORDER BY A.[name]
GO
