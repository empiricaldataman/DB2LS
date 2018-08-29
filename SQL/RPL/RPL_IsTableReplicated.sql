:CONNECT M1
USE DBA
GO
SET NOCOUNT ON


SELECT *
  FROM [dbo].[Publications]
 WHERE article_name = 'ContractDetail'
   AND publisher_database = 'Servicing'
 ORDER BY load_date DESC
GO