/*-------------------------------------------------------------------------------------------------
        NAME: DBA_SERVERPROPERTY.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Returns property information about the server instance.
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    11.19.2013  SYoung        Initial creation.
--            07.13.2018  SYoung        Added new properties: 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SELECT SERVERPROPERTY('BuildClrVersion')              [BuildClrVersion]              -- Version of the Microsoft .NET Framework CLR nvarchar(128) 
     , SERVERPROPERTY('Collation')                    [Collation]                    -- Name of the default collation for the server nvarchar(128)
     , SERVERPROPERTY('CollationID')                  [CollationID]                  -- ID of the SQL Server collation. int
     , SERVERPROPERTY('ComparisonStyle')              [ComparisonStyle]              -- Windows comparison style of the collation int
     , SERVERPROPERTY('ComputerNamePhysicalNetBIOS')  [ComputerNamePhysicalNetBIOS]  -- The local computer on which the instance of SQL Server is currently running. The active node of a SQL cluster
     , SERVERPROPERTY('Edition')                      [Edition]                      -- Installed product edition of the instance of SQL Server nvarchar(128)
     , SERVERPROPERTY('EditionID')                    [EditionID]                    -- The installed product edition of the instance of SQL Server. bigint
     , SERVERPROPERTY('EngineEdition')                [EngineEdition]                -- Database Engine edition of the instance of SQL Server installed on the server. int
     , SERVERPROPERTY('ErrorLogFileName')             [ErrorLogFileName]             --
     , SERVERPROPERTY('HadrManagerStatus')            [HadrManagerStatus]            -- Indicates whether the AlwaysOn Availability Groups manager has started.
     , SERVERPROPERTY('InstanceDefaultDataPath')      [InstanceDefaultDataPath]      -- NEW Name of the default path to the instance data files.
     , SERVERPROPERTY('InstanceDefaultLogPath')       [InstanceDefaultLogPath]       -- NEW Name of the default path to the instance log files.
     , SERVERPROPERTY('InstanceName')                 [InstanceName]                 -- Name of the instance to which the user is connected. nvarchar(128)
     , SERVERPROPERTY('IsAdvancedAnalyticsInstalled') [IsAdvancedAnalyticsInstalled] -- NEW Returns 1 if the Advanced Analytics feature was installed during setup; 0 if Advanced Analytics was not installed. int
     , SERVERPROPERTY('IsClustered')                  [IsClustered]                  -- Server instance is configured in a failover cluster. int
     , SERVERPROPERTY('IsFullTextInstalled')          [IsFullTextInstalled]          -- The full-text and semantic indexing components are installed on the current instance of SQL Server. int
     , SERVERPROPERTY('IsHadrEnabled')                [IsHadrEnabled]                -- AlwaysOn Availability Groups is enabled on this server instance. int
     , SERVERPROPERTY('IsIntegratedSecurityOnly')     [IsIntegratedSecurityOnly]     -- Server is in integrated security mode. int
     , SERVERPROPERTY('IsLocalDB')                    [IsLocalDB]                    -- Server is an instance of SQL Server Express LocalDB.
     , SERVERPROPERTY('IsPolybaseInstalled')          [IsPolybaseInstalled]          -- NEW Returns whether the server instance has the PolyBase feature installed.
     , SERVERPROPERTY('IsSingleUser')                 [IsSingleUser]                 -- Server is in single-user mode. int
     , SERVERPROPERTY('IsXTPSupported')               [IsXTPSupported]               -- Server supports In-Memory OLTP.  
     , SERVERPROPERTY('LCID')                         [LCID]                         -- Windows locale identifier (LCID) of the collation. int
     , SERVERPROPERTY('LicenseType')                  [LicenseType]                  -- NEW Unused. License information is not preserved or maintained by the SQL Server product. Always returns DISABLED.
     , SERVERPROPERTY('MachineName')                  [MachineName]                  -- Windows computer name on which the server instance is running. The name of the failover clustered instance,
     , SERVERPROPERTY('NumLicenses')                  [NumLicenses]                  -- NEW Unused. License information is not preserved or maintained by the SQL Server product. Always returns NULL.
     , SERVERPROPERTY('ProcessID')                    [ProcessID]                    -- Process ID of the SQL Server service. ProcessID is useful in identifying which Sqlservr.exe belongs to this instance. int
     , SERVERPROPERTY('ProductBuild')                 [ProductBuild]                 -- NEW Applies to: SQL Server 2014 (12.x) beginning October, 2015.
     , SERVERPROPERTY('ProductBuildType')             [ProductBuildType]             -- NEW Type of build of the current build.
     , SERVERPROPERTY('ProductLevel')                 [ProductLevel]                 -- Level of the version of the instance of SQL Server.
     , SERVERPROPERTY('ProductMajorVersion')          [ProductMajorVersion]          -- NEW The major version.
     , SERVERPROPERTY('ProductMinorVersion')          [ProductMinorVersion]          -- NEW The minor version.
     , SERVERPROPERTY('ProductUpdateLevel')           [ProductUpdateLevel]           -- NEW Update level of the current build. CU indicates a cumulative update.
     , SERVERPROPERTY('ProductUpdateReference')       [ProductUpdateReference]       -- NEW Applies to: SQL Server 2012 (11.x) through current version in updates beginning in late 2015.
     , SERVERPROPERTY('ProductVersion')               [ProductVersion]               -- Version of the instance of SQL Server, in the form of 'major.minor.build.revision'. nvarchar(128)
     , SERVERPROPERTY('ResourceLastUpdateDateTime')   [ResourceLastUpdateDateTime]   -- Date and time that the Resource database was last updated. datetime
     , SERVERPROPERTY('ResourceVersion')              [ResourceVersion]              -- Returns the version Resource database. nvarchar(128)
     , SERVERPROPERTY('ServerName')                   [ServerName]                   -- Both the Windows server and instance information associated with a specified instance of SQL Server. nvarchar(128)
     , SERVERPROPERTY('SqlCharSet')                   [SqlCharSet]                   -- The SQL character set ID from the collation ID. tinyint
     , SERVERPROPERTY('SqlCharSetName')               [SqlCharSetName]               -- The SQL character set name from the collation. nvarchar(128)
     , SERVERPROPERTY('SqlSortOrder')                 [SqlSortOrder]                 -- The SQL sort order ID from the collation tinyint
     , SERVERPROPERTY('SqlSortOrderName')             [SqlSortOrderName]             -- The SQL sort order name from the collation. nvarchar(128)
     , SERVERPROPERTY('FilestreamShareName')          [FilestreamShareName]          -- The name of the share used by FILESTREAM.
     , SERVERPROPERTY('FilestreamConfiguredLevel')    [FilestreamConfiguredLevel]    -- NEW The configured level of FILESTREAM access. For more information, see filestream access level.
     , SERVERPROPERTY('FilestreamEffectiveLevel')     [FilestreamEffectiveLevel]     -- NEW The effective level of FILESTREAM access. This value can be different than the FilestreamConfiguredLevel if the level has changed and either an instance restart or a computer restart is pending. For more information, see filestream access level.
GO