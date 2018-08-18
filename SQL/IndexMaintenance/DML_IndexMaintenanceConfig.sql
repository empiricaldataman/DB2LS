USE msdb
GO

SET IDENTITY_INSERT [IndexMaintenanceConfig] ON

INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (1,'RCHPWVMGMSQL01\MANAGEMENT01','DatabasesToExclude','master,msdb,distribution,tempdb,dba_backup,SQLImplementations,model,ReportServer,ReportServerTempDB,sysutility_mdw')
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (2,'RCHPWVMGMSQL01\MANAGEMENT01','DayToCollect','Friday')
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (3,'RCHPWVMGMSQL01\MANAGEMENT01','FragmentationPercentage','25.0')
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (4,'RCHPWVMGMSQL01\MANAGEMENT01','TimeToStopCollecting','08:00')
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (5,'RCHPWVMGMSQL01\MANAGEMENT01','TimeToStopRebuilding','08:00')
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (6,'RCHPWVMGMSQL01\MANAGEMENT01','LargeDBSize',20000)
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (8,'RCHPWVMGMSQL01\MANAGEMENT01','PageCount',1000)
INSERT INTO dbo.IndexMaintenanceConfig (configuration_id, [instance_name], [name], [value]) VALUES (9,'RCHPWVMGMSQL01\MANAGEMENT01','DayToRebuild','Saturday')

SET IDENTITY_INSERT [IndexMaintenanceConfig] OFF
