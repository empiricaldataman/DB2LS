
CREATE TABLE [dbo].[Statistics](
	[collection_time] [datetime] NOT NULL,
	[instance_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [sysname] NOT NULL,
	[table_name] [sysname] NOT NULL,
	[stat_name] [nvarchar](128) NULL,
	[stat_last_updated] [datetime2](7) NULL,
	[rows_in_table] [bigint] NULL,
	[rows_modified] [bigint] NULL,
	[rows_modified_percent] [decimal](18, 2) NULL)
GO

CREATE CLUSTERED INDEX cix_Statistics_collection_time ON [dbo].[Statistics] (collection_time)
GO
