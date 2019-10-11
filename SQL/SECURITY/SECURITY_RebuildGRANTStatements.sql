:CONNECT M1
USE DBA
GO

SET NOCOUNT ON

DECLARE @load_date date
      , @instance_name varchar(100)
      , @user_name varchar(100)

SET @instance_name = 'DDSQL01\WAREHOUSE'
SET @user_name = 'BRR\DEV'
SELECT @load_date = '20140414'  -- MAX(load_date) FROM dbo.Users

SELECT database_name,[user_name],database_role,load_date,instance_name 
INTO #TmpPermissions
FROM users
WHERE load_date = @load_date 
AND instance_name = @instance_name
AND [user_name] LIKE '%'+ @user_name +'%'
AND database_name NOT IN ('tempdb','master','model')
;

DECLARE @old_dbname varchar(100) = '';
DECLARE @old_username varchar(100) = '';
DECLARE @database_name varchar(100) = '';
DECLARE @login_name varchar(100) = '';
DECLARE @database_role varchar(50) = '';

DECLARE  CurCreatePermissions CURSOR FOR
SELECT database_name,[user_name],database_role
FROM #TmpPermissions
ORDER BY database_name,[user_name],database_role;

OPEN CurCreatePermissions
FETCH NEXT FROM  CurCreatePermissions INTO @database_name,@user_name,@database_role
WHILE (@@FETCH_STATUS != -1)
BEGIN

       IF (@database_name <> @old_dbname) 
       BEGIN
              PRINT N'USE ['+ @database_name +']'+ CHAR(10) +
                           'GO'+ CHAR(10)
              PRINT 'IF EXISTS (SELECT * FROM sys.sysusers WHERE [name] = '''+ @user_name +''')'+ CHAR(10) +
                           'DROP USER ['+ @user_name +']'+ CHAR(10) +
                           'GO'+ CHAR(10) +
                           'CREATE USER ['+ @user_name +'] FOR LOGIN ['+ @user_name +']'+ CHAR(10) +
                           'GO'+ CHAR(10)
                     PRINT 'ALTER ROLE ['+ @database_role +'] ADD MEMBER ['+ @user_name +']'+ CHAR(10) + 
                     'GO'+ CHAR(10) 
       END
       ELSE
       BEGIN                
              If (@user_name <> @old_username)
              BEGIN
                     PRINT 'IF EXISTS (SELECT * FROM sys.sysusers WHERE [name] = '''+ @user_name +''')'+ CHAR(10) +
                           'DROP USER ['+ @user_name +']'+ CHAR(10) +
                           'GO'+ CHAR(10) +
                           'CREATE USER ['+ @user_name +'] FOR LOGIN ['+ @user_name +']'+ CHAR(10) +
                           'GO'+ CHAR(10)
                     PRINT 'ALTER ROLE ['+ @database_role +'] ADD MEMBER ['+ @user_name +']'+ CHAR(10) + 
                     'GO'+ CHAR(10)
              END
              ELSE
              BEGIN
                     PRINT 'ALTER ROLE ['+ @database_role +'] ADD MEMBER ['+ @user_name +']'+ CHAR(10) + 
                     'GO'+ CHAR(10)
              END
       END
       
       set @old_dbname = @database_name;
       set @old_username = @user_name ;
       FETCH NEXT FROM  CurCreatePermissions INTO @database_name,@user_name,@database_role
END  
CLOSE CurCreatePermissions
DEALLOCATE CurCreatePermissions

DROP TABLE #TmpPermissions
