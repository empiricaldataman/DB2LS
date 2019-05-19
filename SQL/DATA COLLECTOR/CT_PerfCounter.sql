IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PerfCounter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PerfCounter](
	[collection_time] [datetime] NOT NULL,
	[processes_blocked] [bigint] NULL,
	[user_connections] [int] NULL,
	[free_list_stalls_sec] [bigint] NULL,
	[lazy_writes_sec] [bigint] NULL,
	[page_life_expectancy] [bigint] NULL,
	[full_scans_sec] [bigint] NULL,
	[index_searches_sec] [bigint] NULL,
	[batch_requests_sec] [bigint] NULL,
	[sql_compilations_sec] [bigint] NULL,
	[sql_re-compilations_sec] [bigint] NULL,
	[memory_grants_pending] [bigint] NULL)
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PerfCounter]') AND name = N'CIX_PerfCounter_collection_time')
CREATE CLUSTERED INDEX [CIX_PerfCounter_collection_time] ON [dbo].[PerfCounter]
([collection_time] ASC)
GO
