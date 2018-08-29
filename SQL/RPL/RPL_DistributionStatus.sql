/*-------------------------------------------------------------------------------------------------
        NAME: RPL_DistributionStatus.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use this script to get count of distributed and pending commands.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:CONNECT PO
USE Distribution
GO

SET NOCOUNT ON

--IF OBJECT_ID(N'DBA_BACKUP..DistributionAnalysis','U') IS NULL
--   BEGIN
--   CREATE TABLE DBA_BACKUP..DistributionAnalysis (
--          dCreated smalldatetime
--        , article_id int
--        , agent_id int
--        , UndelivCmdsInDistDB int
--        , DelivCmdsInDistDB int
--        , job_name varchar(128)
--        , publisher_db varchar(128)
--        , publication varchar(128)
--        , article_name varchar(800))
--END

--INSERT INTO DBA_BACKUP..DistributionAnalysis (
--       dCreated
--     , article_id
--     , agent_id
--     , UndelivCmdsInDistDB
--     , DelivCmdsInDistDB
--     , job_name
--     , publisher_db
--     , publication
--     , article_name)

SELECT DS.[article_id]
     , DS.[agent_id]
     , DS.[UndelivCmdsInDistDB]
     , DS.[DelivCmdsInDistDB]
     , DA.[name] [JobName]
     , DA.publisher_db
     , DA.publication
    --, DA.*
  FROM [dbo].[MSdistribution_status] DS WITH (NOLOCK)
 INNER JOIN [dbo].[msdistribution_agents] DA WITH (NOLOCK) ON DS.agent_id = DA.id
 --INNER JOIN [Cars_Net].[sys].[dm_repl_articles] RA WITH (NOLOCK) ON DS.article_id = RA.artid
 --WHERE DA.[name] LIKE 'REPL-DIST-PR-Cars_Net - Reporting%'
 
--WAITFOR DELAY '00:01:00'
--GO 5




:CONNECT PO
USE DBA_BACKUP
GO

DECLARE @tabla table(
        Subscriber_db varchar(100)
      , Publisher_db varchar(100)
      , Publication varchar(200)
      , Article varchar(100)
      , UndelivCmdsInDistDB bigint
      , DelivCmdsInDistDB bigint
      , Srvname varchar(50))

INSERT @tabla
SELECT b.subscriber_db
     , b.publisher_db
     , c.publication
     , d.article
     , a.UndelivCmdsInDistDB
     , a.DelivCmdsInDistDB
     , e.srvname
  FROM distribution..MSdistribution_status a  WITH (NOLOCK)
 INNER JOIN distribution..MSdistribution_agents b  WITH (NOLOCK) ON a.agent_id = b.id
 INNER JOIN distribution..MSpublications c  WITH (NOLOCK) ON b.publication = c.publication
 INNER JOIN distribution..MSarticles d  WITH (NOLOCK) ON (a.article_id = d.article_id 
   AND c.publication_id=d.publication_id)
 INNER JOIN master..sysservers e  WITH (NOLOCK) ON b.subscriber_id = e.srvid
 WHERE b.subscriber_db <> 'virtual'
   AND a.UndelivCmdsInDistDB > 0
   AND b.publisher_db = 'Credit'
   AND b.[name] LIKE 'REPL-DIST-PR-Credit - Reporting - %'
 ORDER BY b.subscriber_db ASC, a.UndelivCmdsInDistDB DESC
 
SELECT Subscriber_db as 'Subscriptor'
     , Publication as 'Publicacion'
     , sum(UndelivCmdsInDistDB) as 'Faltan Replicar'
     , Srvname as 'Servidor Destino'
  FROM @tabla
 GROUP BY Subscriber_db, Publication,Srvname
HAVING SUM(UndelivCmdsInDistDB)>0
 ORDER BY SUM(UndelivCmdsInDistDB) DESC, Publication ASC

SELECT Subscriber_db as 'Subscriptor'
     , Publisher_db
     , Publication as 'Publicacion'
     , Article as 'Tabla'
     , UndelivCmdsInDistDB as 'Faltan por Replicar'
     , DelivCmdsInDistDB as 'Total en Historico'
     , Srvname as 'Servidor Destino'
 FROM @tabla
GO