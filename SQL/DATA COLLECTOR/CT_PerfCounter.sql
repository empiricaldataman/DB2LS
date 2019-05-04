IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PerfCounter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PerfCounter](
	[collection_time] [datetime] NOT NULL,
	[processes_blocked] [int] NULL,
	[user_connections] [int] NULL,
	[free_list_stalls_sec] [int] NULL,
	[lazy_writes_sec] [int] NULL,
	[page_life_expectancy] [int] NULL,
	[full_scans_sec] [int] NULL,
	[index_searches_sec] [int] NULL,
	[batch_requests_sec] [int] NULL,
	[sql_compilations_sec] [int] NULL,
	[sql_re-compilations_sec] [int] NULL,
	[memory_grants_pending] [int] NULL)
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PerfCounter]') AND name = N'CIX_PerfCounter_collection_time')
CREATE CLUSTERED INDEX [CIX_PerfCounter_collection_time] ON [dbo].[PerfCounter]
([collection_time] ASC)
GO
