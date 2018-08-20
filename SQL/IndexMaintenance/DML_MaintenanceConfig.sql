
INSERT INTO dbo.MaintenanceConfig (
       ConfigurationType
     , ConfigurationSettings)
VALUES ('IndexMaintenance'
     , '<IndexMaintenanceSettings>
    <SQLInstance Name="RCHPWCCRPSQL01B\ORIGINATIONS">
        <DatabasesToExclude>master,msdb,distribution,tempdb,dba_backup,model,Credit</DatabasesToExclude>
        <DayToCollect>Sunday,Tuesday,Thursday</DayToCollect>
        <DayToRebuild>Monday,Wednesday,Friday</DayToRebuild>
        <FragmentationPercentage>25.0</FragmentationPercentage>
        <LargeDBSize>20000</LargeDBSize>
        <PageCount>1000</PageCount>
        <TimeToStopCollecting>05:00</TimeToStopCollecting>
        <TimeToStopRebuilding>05:00</TimeToStopRebuilding>
        <DatabasesL1>Credit</DatabasesL1>
    </SQLInstance>
</IndexMaintenanceSettings>')

INSERT INTO dbo.MaintenanceConfig (
       ConfigurationType
     , ConfigurationSettings)
VALUES ('StatisticsMaintenance'
     , '<StatisticsSettings>
    <SQLInstance Name="RCHPWCCRPSQL01B\ORIGINATIONS">
        <DatabasesToExclude>master,msdb,distribution,tempdb,dba_backup,model</DatabasesToExclude>
        <DayToCollect>Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday</DayToCollect>
        <DayToUpdate>Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday</DayToUpdate>
        <ModifiedPercentage>0.001</ModifiedPercentage>
        <ModifiedRows>100</ModifiedRows>
        <TimeToStopCollecting>23:59</TimeToStopCollecting>
        <TimeToStopUpdating>23:59</TimeToStopUpdating>
    </SQLInstance>
</StatisticsSettings>')
