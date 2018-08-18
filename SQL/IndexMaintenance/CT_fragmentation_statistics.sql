USE [DBA_Backup]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[fragmentation_statistics](
	[load_date_start] [smalldatetime] NOT NULL,
	[load_date_end] [smalldatetime] NULL,
	[database_name] [sysname] NOT NULL,
	[schema_name] [sysname] NOT NULL,
	[object_id] [int] NULL,
	[table_name] [nvarchar](128) NULL,
	[index_id] [int] NULL,
	[index_name] [sysname] NULL,
	[partition_number] [int] NULL,
	[page_count] [bigint] NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[avg_page_space_used_in_percent] [float] NULL,
	[maintenance_start] [smalldatetime] NULL,
	[maintenance_end] [smalldatetime] NULL,
	[active] [tinyint] NULL,
	[large_db] [tinyint] NOT NULL,
	[error_message] [varchar](256) NULL
) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [CIX_fragmentation_statistics_load_date_start] ON [dbo].[fragmentation_statistics]
(
	[load_date_start] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [ix_fragmentation_statistics_database_name_object_id_index_id_active] ON [dbo].[fragmentation_statistics]
(
	[database_name] ASC,
	[object_id] ASC,
	[index_id] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[fragmentation_statistics] ADD  DEFAULT ((1)) FOR [active]
GO