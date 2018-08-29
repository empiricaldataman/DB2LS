/*-------------------------------------------------------------------------------------------------
        NAME: DBA_VLF.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to do analysis of VLF (Virtual Log Files) on all databases on a SQL 
              instance.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT PR
USE tempdb
GO
IF OBJECT_ID('tempdb..sp_LOGINFOt','U') IS NOT NULL
   DROP TABLE tempdb..sp_LOGINFOt
GO
IF OBJECT_ID('tempdb..sp_LOGINFO','U') IS NOT NULL
   DROP TABLE tempdb..sp_LOGINFO
GO

CREATE TABLE dbo.sp_LOGINFOt (
       RecoveryUnitId smallint,
       FileId tinyint,
       FileSize bigint,
       StartOffset bigint,
       FSeqNo int,
       [Status] tinyint,
       Parity tinyint,
       CreateLSN numeric(25,0));
GO

CREATE TABLE dbo.sp_LOGINFO (
       CaptureDate smalldatetime,
       DBName varchar(128),
       RecoveryUnitId smallint,
       FileId tinyint,
       FileSize bigint,
       StartOffset bigint,
       FSeqNo int,
       [Status] tinyint,
       Parity tinyint,
       CreateLSN numeric(25,0));
GO


USE master
GO
EXEC sp_msforeachdb N'USE [?]; INSERT INTO tempdb.dbo.sp_LOGINFOt EXEC (''DBCC LOGINFO''); INSERT INTO tempdb.dbo.sp_LOGINFO SELECT GETDATE(), ''?'' AS DBNAME, RecoveryUnitId, FileId, FileSize, StartOffset, FSeqNo, [Status], Parity, CreateLSN FROM tempdb.dbo.sp_LOGINFOt; TRUNCATE TABLE tempdb.dbo.sp_LOGINFOt'

SELECT COUNT(*)
     , DBName 
  FROM tempdb..sp_LOGINFO 
 GROUP BY DBName 
 ORDER BY 1 DESC

SELECT * 
  FROM tempdb..sp_LOGINFO 
 WHERE DBName = 'RevolvingCredit_ODS'