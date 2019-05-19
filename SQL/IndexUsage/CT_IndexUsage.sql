USE [DBA]
GO

CREATE TABLE [dbo].[IndexUsage](
	[dCaptured] [datetime] NOT NULL,
	[ServerName] [varchar](128) NOT NULL,
	[DBName] [varchar](128) NOT NULL,
	[SchemaName] [varchar](128) NOT NULL,
	[TableName] [nvarchar](128) NOT NULL,
	[IndexName] [nvarchar](128) NULL,
	[IndexSeeks] [bigint] NULL,
	[IndexScans] [bigint] NULL,
	[IndexLookups] [bigint] NULL,
	[IndexUpdates] [bigint] NULL,
	[LastUsed] [datetime] NULL,
	[LastUpdated] [datetime] NULL,
	[daysServer_up] [int] NULL)
GO

CREATE CLUSTERED INDEX [CIX_IndexUsage_dCaptured] ON [dbo].[IndexUsage] (
	[dCaptured] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_IndexUsage_DBName] ON [dbo].[IndexUsage] (
	[DBName] ASC)
INCLUDE ([ServerName],
	[SchemaName],
	[TableName],
	[IndexName],
	[IndexSeeks],
	[IndexScans],
	[IndexLookups],
	[IndexUpdates],
	[LastUsed],
	[LastUpdated],
	[daysServer_up])
GO


