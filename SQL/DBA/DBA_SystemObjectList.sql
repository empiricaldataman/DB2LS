/*
-------------------------------------------------------------------------------------------------
        NAME: DBA_SystemObjectList.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays list of all system object (DMV, Catalog tables, system functions)
-------------------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- TR/PROJ#    DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000     10.09.2017  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

SELECT S.[name] [schema_name]
     , O.[name] [object_name]
     , O.xtype [object_type]
     , CASE O.xtype WHEN 'V'  THEN 'VIEW'
                    WHEN 'X'  THEN 'PROCEDURE EXTENDED'
                    WHEN 'S'  THEN 'SYSTEM CATALOG'
                    WHEN 'IT' THEN 'TABLE INTERNAL'
                    WHEN 'U'  THEN 'TABLE'
                    WHEN 'IF' THEN 'FUNCTION IN-LINE TABLE'
                    WHEN 'AF' THEN 'GEOMETRY'
                    WHEN 'FS' THEN 'FUNCTION ASSEMBLY'
                    WHEN 'P'  THEN 'PROCEDURE'
                    WHEN 'PC' THEN 'PROCEDURE ASSEMBLY'
                    WHEN 'FN' THEN 'FUNCTION SCALAR'
                    WHEN 'TF' THEN 'FUNCTION TABLE'
                    ELSE 'UNKNOWN' END [object_type_description]
  FROM sys.sysobjects O
 INNER JOIN sys.schemas S ON O.uid = S.[schema_id]
 WHERE S.[name] = 'sys'
 ORDER BY O.xtype, O.[name]

