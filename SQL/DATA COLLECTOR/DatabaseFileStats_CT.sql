
CREATE TABLE [dbo].[DatabaseFileStats](
	[date] [datetime] NOT NULL,
	[instance_name] [varchar](128) NULL,
	[database_name] [nvarchar](256) NULL,
	[file_name] [nvarchar](256) NULL,
	[mount_point] [varchar](200) NULL,
	[file_path] [varchar](200) NULL,
	[size] [int] NULL,
	[used] [int] NULL,
	[free] [int] NULL,
	[pct] [varchar](6) NULL,
	[growth] [varchar](6) NULL,
	[max] [bigint] NULL,
	[drive_size] [int] NULL,
	[drive_free] [int] NULL
) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [CIX_RDX_DatabaseFileStats_date] ON [dbo].[DatabaseFileStats]
(
	[date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


