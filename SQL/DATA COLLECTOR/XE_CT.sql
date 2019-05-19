IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[XE_Monitor_Performance]') AND type in (N'U'))
   BEGIN
   CREATE TABLE [dbo].[XE_Monitor_Performance](
          [name] [varchar](128) NULL
        , [timestamp] [datetime] NULL
        , [timestamp (UTC)] [datetimeoffset](7) NULL
        , [cpu_time] [decimal](28, 0) NULL
        , [duration] [decimal](28, 0) NULL
        , [physical_reads] [decimal](28, 0) NULL
        , [logical_reads] [decimal](28, 0) NULL
        , [writes] [decimal](28, 0) NULL
        , [result] [varchar](64) NULL
        , [row_count] [decimal](20, 0) NULL
        , [connection_reset_option] [varchar](128) NULL
        , [object_name] [nvarchar](256) NULL
        , [statement] [nvarchar](max) NULL
        , [data_stream] [varbinary](max) NULL
        , [output_parameters] [varchar](256) NULL
        , [username] [varchar](128) NULL
        , [transaction_sequence] [decimal](20, 0) NULL
        , [transaction_id] [bigint] NULL
        , [session_id] [int] NULL
        , [server_principal_name] [varchar](128) NULL
        , [query_hash] [decimal](20, 0) NULL
        , [database_name] [varchar](128) NULL
        , [client_hostname] [varchar](128) NULL
        , [spills] [decimal](20, 0) NULL
        , [batch_text] [nvarchar](max) NULL
        , [sql_text] [nvarchar](max) NULL)
     WITH (DATA_COMPRESSION = PAGE)
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[XE_Monitor_Performance]') AND name = N'CIX_XE_Monitor_Performance_timestamp')
CREATE CLUSTERED INDEX [CIX_XE_Monitor_Performance_timestamp] 
    ON [dbo].[XE_Monitor_Performance] (
	     [timestamp] ASC,
	     [session_id] ASC)
  WITH (DATA_COMPRESSION = PAGE)
GO
