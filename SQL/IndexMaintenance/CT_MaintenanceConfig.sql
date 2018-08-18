USE [msdb]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IndexMaintenanceConfig](
	[configuration_id] [smallint] IDENTITY(1,1) NOT NULL,
	[instance_name] [varchar](50) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[value] [varchar](4000) NOT NULL,
 CONSTRAINT [PK_IndexMaintenaceConfig] PRIMARY KEY CLUSTERED 
(
	[configuration_id] ASC,
	[instance_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO