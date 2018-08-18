USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
	[daysServer_up] [int] NULL
)
GO

CREATE CLUSTERED INDEX [CIX_IndexUsage_dCaptured] ON [dbo].[IndexUsage]
(
	[dCaptured] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_IndexUsage_DBName] ON [dbo].[IndexUsage]
(
	[DBName] ASC
)
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
	[daysServer_up]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


