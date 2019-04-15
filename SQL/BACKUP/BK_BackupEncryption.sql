/*-----------------------------------------------------------------------------------------------
        NAME: BK_BackupEncryption.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: EXAMPLE OF HOW TO ENCRYPT A BACKUP ON ONE SERVER AND RESTORE ON ANOTHER USING SQL SERVER BACKUP ENCRYPTION.
              YOU WILL NEED TWO SQL INSTANCES. IN THIS EXAMPLE, I USED "YOGA920" (SOURCE) RUNNING SQL Server 2016 (SP2-CU2-GDR)
              13.0.5201.2 AND "SERVER6\SEVENTEEN" (TARGET) RUNNING SQL Server 2017 (RTM-CU10) 14.0.3037.1
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

----------------------------------------------------------------------------------------------------------------
--[ ON YOGA920
--[ 1. CREATE THE master KEY. THIS KEY IS USED TO ENCRYPT THE CERTIFICATE.
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YOGA920_MASTER_KEY_PASSWORD'
GO

--[ 2. BACKUP THE master KEY AND SAVE IT IN A SAFE PLACE.
BACKUP MASTER KEY
    TO FILE = N'C:\INSTALL\YOGA920_master.key'
       ENCRYPTION BY PASSWORD = 'MasterKeyPassword';
GO

--[ 3. CREATE THE CERTIFICATE TO BE USED FOR BACKUP ENCRYPTION.
CREATE CERTIFICATE BACKUPCert
  WITH SUBJECT = 'Backup Encryption Certificate'
GO

--[ 4. BACKUP THE CERTIFICATE AS THIS WILL NEED TO BE USED ON THE TARGET SQL INSTANCE.
BACKUP CERTIFICATE BACKUPCert
    TO FILE = 'C:\INSTALL\YOGA920_BackupCert.cer'
  WITH PRIVATE KEY (FILE = 'C:\INSTALL\YOGA920_BackupCert_PrivateKey.key', ENCRYPTION BY PASSWORD = 'CertificatePassword');
GO

--[ 5 BACKUP THE DATABASE USING THE ENCRYPTION OPTION AND THE CERTIFICATE CREATED ABOVE ON STEP 3.
BACKUP DATABASE DPR2
    TO DISK = N'C:\INSTALL\DBName_YYYYmmdd_HHmm.ebak'
  WITH COMPRESSION
     , ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = BACKUPCert)
     , STATS = 5
GO


----------------------------------------------------------------------------------------------------------------
--[ ON SERVER6\SEVENTEEN
--[ 1. COPY FILES CREATED AT THE SOURCE (YOGA920_BackupCert_PrivateKey.key, YOGA920_BackupCert.cer, AND 
--[    DBName_YYYYmmdd_HHmm.ebak) TO A LOCATION WHERE THE TARGET SQL INSTANCE CAN READ THEM.


--[ 2. CREATE THE master KEY. IT DOESN'T HAVE TO USE THE SAME PASSWORD AS THE SOURCE (YOGA920).
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SERVER6\SEVENTEEN_MASTER_KEY_PASSWORD'
GO

--[ 3. CREATE THE CERTIFICATE TO BE USED FOR RESTORING ENCRYPTED BACKUPS FROM YOGA920 SQL INSTANCE. NOTICE WE DO
--[    NOT USE A "RESTORE CERTIFICATE" COMMAND.
CREATE CERTIFICATE BACKUPCert
  FROM FILE = N'C:\INSTALL\YOGA920_BackupCert.cer'
  WITH PRIVATE KEY (FILE = 'C:\INSTALL\YOGA920_BackupCert_PrivateKey.key', DECRYPTION BY PASSWORD = 'CertificatePassword');
GO

--[ 4. RESTORE DATABASE 
RESTORE DATABASE [DBName] 
   FROM DISK = N'C:\INSTALL\DBName_YYYYmmdd_HHmm.ebak'
   WITH FILE = 1
      , MOVE N'DPR' TO N'F:\Program Files\Microsoft SQL Server\MSSQL14.SEVENTEEN\MSSQL\DATA\DBName.mdf'
	  , MOVE N'DPR_log' TO N'L:\Program Files\Microsoft SQL Server\MSSQL14.SEVENTEEN\MSSQL\Data\DBName_log.ldf'
	  , NOUNLOAD
	  , STATS = 5
GO
--[ IF YOU TRY TO RESTORE THE AN ENCRYPTED DATABASE WITHOUT THE CERTIFICATE, YOU WILL GET AN ERROR LIKE
--[ -------------------------------------------------------------------------------------------------------------
--[ Msg 33111, Level 16, State 3, Line 7
--[ Cannot find server certificate with thumbprint '0x586BB12BDB26380FE1785CAFDBC81B91BEAFD1C0'.
--[ Msg 3013, Level 16, State 1, Line 7
--[ RESTORE DATABASE is terminating abnormally.
--[ -------------------------------------------------------------------------------------------------------------


--[ THESE DMVs ARE USED THROUGHOUT THIS TEST TO REVIEW THE KEYS AND CERTIFICATES ON THE SQL INSTANCES
SELECT * FROM sys.symmetric_keys
SELECT * FROM sys.dm_database_encryption_keys
SELECT * FROM sys.certificates






