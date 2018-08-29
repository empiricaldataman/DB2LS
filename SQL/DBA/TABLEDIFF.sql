/*-------------------------------------------------------------------------------------------------
        NAME: CMD_TABLEDIFF.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: It creates C:\temp\$(table).sql file with DML to bring the table in the destination
              SQL instance in sync with the table in the source.  You must have the tablediff.exe
              referenced in your path in order for this to work.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    07.21.2016  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:setvar sourceserver "<server_name_source, sysname, SQL instance source>"
:setvar destinationserver "<server_name_target, sysname, SQL instance target>"


:setvar database "<database_name, sysname, Database name>"
:setvar schema "<schema_name_target, sysname, Schema>"
:setvar table "<table_name, sysname, Table name>"
:!!tablediff.exe -sourceserver $(sourceserver) -sourcedatabase $(database) -sourceschema $(schema) -sourcetable $(table) -destinationserver $(destinationserver) -destinationdatabase $(database) -destinationschema $(schema) -destinationtable $(table) -c -f C:\temp\$(table).sql

