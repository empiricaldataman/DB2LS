/*-----------------------------------------------------------------------------------------------
        NAME: DBA_SchemaChange_Capture_CT.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Creates the table to keep data captured by "Schema Change" job
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    04.14.2019  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SchemaChange]') AND type in (N'U'))
   BEGIN
   CREATE TABLE [dbo].[SchemaChange](
          [id] [bigint] IDENTITY(1,1) NOT NULL
        , [difference] [int] NULL
        , [date] [datetime] NULL
        , [obj_type_desc] [int] NULL
        , [l1] [bigint] NULL
        , [l2] [bigint] NULL
        , [obj_name] [varchar](128) NULL
        , [obj_id] [int] NULL
        , [database_name] [varchar](128) NULL
        , [start_time] [datetime] NULL
        , [event_class] [int] NULL
        , [event_subclass] [int] NULL
        , [object_type] [int] NULL
        , [server_name] [varchar](128) NULL
        , [login_name] [varchar](128) NULL
        , [user_name] [varchar](128) NULL
        , [application_name] [varchar](128) NULL
        , [ddl_operation] [varchar](128) NULL
        , CONSTRAINT [PK_SchemaChange] PRIMARY KEY CLUSTERED (
   	      [id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        , CONSTRAINT [IX_SchemaChange] UNIQUE NONCLUSTERED (
          [start_time] ASC
        , [obj_id] ASC
        , [database_name] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
   ) ON [PRIMARY]
END
GO
