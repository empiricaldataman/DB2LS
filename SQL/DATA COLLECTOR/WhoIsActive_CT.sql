USE [DBA]
GO

IF OBJECT_ID(N'dbo.WhoIsActive_logging','U') IS NOT NULL
   DROP TABLE dbo.WhoIsActive_logging
GO

CREATE TABLE [dbo].[WhoIsActive_logging](
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[session_id] [smallint] NOT NULL,
	[sql_text] [xml] NULL,
	[sql_command] [xml] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[CPU] [varchar](30) NULL,
	[tempdb_allocations] [varchar](30) NULL,
	[tempdb_current] [varchar](30) NULL,
	[blocking_session_id] [smallint] NULL,
	[reads] [varchar](30) NULL,
	[writes] [varchar](30) NULL,
	[physical_reads] [varchar](30) NULL,
	[query_plan] [xml] NULL,
	[locks] [xml] NULL,
	[used_memory] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[open_tran_count] [varchar](30) NULL,
	[percent_complete] [varchar](30) NULL,
	[host_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[additional_info] [xml] NULL,
	[start_time] [datetime] NOT NULL,
	[login_time] [datetime] NULL,
	[request_id] [int] NULL,
	[collection_time] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [CIX_WhoIsActive_logging_collection_time] ON [dbo].[WhoIsActive_logging]
(
	[collection_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION=PAGE) ON [PRIMARY]
GO
