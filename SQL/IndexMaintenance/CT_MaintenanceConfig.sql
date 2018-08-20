USE [msdb]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MaintenanceConfig](
	[ConfigurationType] [varchar](50) NOT NULL,
	[ConfigurationSettings] [xml] NULL,
 CONSTRAINT [pk_MaintenanceConfig_ConfigurationType] PRIMARY KEY CLUSTERED (
	[ConfigurationType] ASC)
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON))
GO