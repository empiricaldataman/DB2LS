
CREATE TABLE [dbo].[IndexUsage](
	[collection_time] [datetime] NOT NULL,
	[instance_name] [varchar](128) NOT NULL,
	[database_name] [varchar](128) NOT NULL,
	[schema_name] [varchar](128) NOT NULL,
	[table_name] [nvarchar](128) NOT NULL,
	[index_name] [nvarchar](128) NULL,
	[index_seek] [bigint] NULL,
	[index_scan] [bigint] NULL,
	[index_lookup] [bigint] NULL,
	[index_update] [bigint] NULL,
	[last_used] [datetime] NULL,
	[last_updated] [datetime] NULL,
	[days_instance_up] [int] NULL)
GO

CREATE CLUSTERED INDEX [CIX_IndexUsage_collection_time] ON [dbo].[IndexUsage] (
	[collection_time] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_IndexUsage_database_name] ON [dbo].[IndexUsage] (
	[database_name] ASC)
INCLUDE ([instance_name],
	[schema_name],
	[table_name],
	[index_name],
	[index_seek],
	[index_scan],
	[index_lookup],
	[index_update],
	[last_used],
	[last_updated],
	[days_instance_up])
GO


