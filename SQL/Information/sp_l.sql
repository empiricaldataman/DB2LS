IF OBJECT_ID(N'dbo.sp_l','P') IS NOT NULL
   DROP PROCEDURE dbo.sp_l
GO

/*-------------------------------------------------------------------------------------------------
        NAME: sp_l.sql
  UPDATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays information about
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    08.16.2018  SYoung        Re-format T-SQL code
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[sp_l]
       @spid INT = NULL

AS

SET NOCOUNT ON

CREATE TABLE #dm_tran_locks
	(
	request_session_id		INT,
	resource_database_id		INT,
	resource_associated_entity_id	BIGINT,
	resource_type			NVARCHAR(120),
	request_mode			NVARCHAR(120),
	request_status			NVARCHAR(120)
	)

CREATE TABLE #dm_exec_sessions
	(
	session_id			SMALLINT,
	login_name			NVARCHAR(256),
	program_name			NVARCHAR(256)
	)

CREATE TABLE #lock_statistics
	(
	spid				SMALLINT,
	login_name			VARCHAR(25),
	database_name			VARCHAR(25),
	entity_id			BIGINT,
	Schema_name			VARCHAR(10),
	object_name			VARCHAR(40),
	index_id			INT,
	index_name			VARCHAR(60),
	lock_type			VARCHAR(15),
	lock_mode			VARCHAR(15),
	lock_status			VARCHAR(5),
	lock_count			BIGINT
	)

IF @spid IS NOT NULL
BEGIN
	INSERT	#dm_tran_locks
	SELECT	request_session_id,
		resource_database_id,
		resource_associated_entity_id,
		resource_type,
		request_mode,
		request_status
	FROM	master.sys.dm_tran_locks WITH (NOLOCK)
	WHERE	resource_type IN ('OBJECT','PAGE','KEY','RID','HOBT')
	AND	request_session_id != @@SPID
	AND	request_session_id  = @spid

	INSERT	#dm_exec_sessions
	SELECT	session_id,
		original_login_name,
		program_name
	FROM	master.sys.dm_exec_sessions WITH (NOLOCK)
	WHERE	session_id != @@SPID
	AND	session_id  = @spid
END
ELSE
BEGIN
	INSERT	#dm_tran_locks
	SELECT	request_session_id,
		resource_database_id,
		resource_associated_entity_id,
		resource_type,
		request_mode,
		request_status
	FROM	master.sys.dm_tran_locks WITH (NOLOCK)
	WHERE	resource_type IN ('OBJECT','PAGE','KEY','RID','HOBT')
	AND	request_session_id != @@SPID

	INSERT	#dm_exec_sessions
	SELECT	session_id,
		original_login_name,
		program_name
	FROM	master.sys.dm_exec_sessions WITH (NOLOCK)
	WHERE	session_id != @@SPID
END

INSERT	#lock_statistics
SELECT 	CONVERT (SMALLINT, vdtl.request_session_id), 
	LEFT(vdes.login_name,25),
	LEFT(DB_NAME(vdtl.resource_database_id),25),
	vdtl.resource_associated_entity_id,
	NULL,
	NULL,
	NULL,
	NULL,
	LEFT(vdtl.resource_type,15),
	LEFT(vdtl.request_mode,15),
	LEFT(vdtl.request_status,5),
	COUNT(*)
FROM 	#dm_tran_locks vdtl
JOIN	#dm_exec_sessions vdes ON vdtl.request_session_id = vdes.session_id
GROUP BY
	CONVERT (SMALLINT, vdtl.request_session_id), 
	LEFT(vdes.login_name,25),
	LEFT(DB_NAME(vdtl.resource_database_id),25),
	vdtl.resource_associated_entity_id,
	vdtl.resource_type,
	vdtl.request_mode,
	vdtl.request_status
		
EXEC	sp_msforeachdb
	'
	USE [?]
	
	UPDATE	#lock_statistics
	SET	schema_name = LEFT(s.name,10),
		object_name = LEFT(o.name,40)
	FROM	#lock_statistics vls
	JOIN	sys.objects o WITH (NOLOCK) ON vls.entity_id = o.object_id
	JOIN	sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id
	WHERE	vls.lock_type in (''OBJECT'')
	AND	vls.database_name = ''?''
 	
	UPDATE	#lock_statistics
	SET	schema_name = LEFT(s.name,10),
		object_name = LEFT(o.name,40),
		index_id = i.index_id,
		index_name = LEFT(i.name,60)
	FROM	#lock_statistics vls
	JOIN	sys.partitions p WITH (NOLOCK) ON vls.entity_id = p.hobt_id
	JOIN	sys.objects o WITH (NOLOCK) ON p.object_id = o.object_id
	JOIN	sys.schemas s WITH (NOLOCK) ON o.schema_id = s.schema_id
	JOIN	sys.indexes i WITH (NOLOCK) ON p.object_id = i.object_id AND p.index_id = i.index_id
	WHERE	vls.lock_type in (''PAGE'',''KEY'',''RID'',''HOBT'')
 	AND	vls.database_name = ''?''
 	'

SELECT	spid,
	login_name,
	database_name,
	schema_name,
	object_name,
	index_name,
	lock_type,
	lock_mode,
	lock_status,
	lock_count
FROM	#lock_statistics
ORDER BY
	spid,
	database_name,
	schema_name,
	object_name,
	index_id,
	lock_type

DROP TABLE #dm_tran_locks
DROP TABLE #dm_exec_sessions
DROP TABLE #lock_statistics
GO
