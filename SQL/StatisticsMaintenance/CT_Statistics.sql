USE [DBA]
GO

CREATE TABLE [dbo].[statistics](
	[load_date] [datetime] NOT NULL,
	[instance_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [sysname] NOT NULL,
	[table_name] [sysname] NOT NULL,
	[stat_name] [nvarchar](128) NULL,
	[stat_last_updated] [datetime2](7) NULL,
	[rows_in_table] [bigint] NULL,
	[rows_modified] [bigint] NULL,
	[per_rows_modified] [decimal](18, 2) NULL)
GO


