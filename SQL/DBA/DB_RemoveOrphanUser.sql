DECLARE @dbname VARCHAR(100),
        @USER VARCHAR(100),
        @login VARCHAR(100),
        @SQL NVARCHAR(2000),
        @version TINYINT,
        @CATALOGNAME nvarchar(128),
        @SCHEMANAME nvarchar(128),
        @OBJECTTYPE nvarchar(20),
        @OBJECTNAME nvarchar(128)

SET NOCOUNT ON

--[ GET SQL SERVER VERSION.  WILL USE FOR DML COMMANDS NOT COMPATIBLE IN ALL VERSIONS ]
SELECT @version = LEFT(CAST(SERVERPROPERTY('productversion') AS varchar(50)),1)

SET @USER = 'MRHEE'

IF OBJECT_ID('tempdb.dbo.##users') IS NULL
   CREATE TABLE ##users ([USER] VARCHAR(100))

IF OBJECT_ID('tempdb.dbo.##Schemas') IS NULL
CREATE TABLE ##Schemas (
       ID int IDENTITY(1,1),
       CATALOGNAME nvarchar(128),
       SCHEMANAME nvarchar(128),
       OBJECTNAME nvarchar(128),
       OBJECTTYPE nvarchar(20))

--[ COLLECT NAME OF ALL DATABASES ON THE SERVER ]
DECLARE crDBname CURSOR FOR
 SELECT [name]
   FROM master.dbo.sysdatabases
  WHERE databasepropertyex([name],'Updateability') = 'READ_WRITE' AND
        databasepropertyex([name], 'status') = 'ONLINE' 
  ORDER BY [name]

--[ COLLECT NAME OF ALL SERVER LOGINS THAT MATCH PATTERN OF LOGIN TO REMOVE ]
DECLARE crLogin CURSOR FOR
 SELECT loginname
   FROM master.dbo.syslogins
  WHERE [name] LIKE '%'+ @USER

--[ REPOSITORY OF ALL DATABASE USERS. IT IS EMPTY INITIALLY ]
DECLARE crUser CURSOR FOR
 SELECT [USER]
   FROM ##users

--[ CHECK FOR THE EXISTANCE OF USER IN EVERY DATABASE ]
   OPEN crDBname
  FETCH NEXT FROM crDBname INTO @dbname
  WHILE @@fetch_status = 0
        BEGIN
        DELETE FROM ##users

        SET @SQL = N'IF EXISTS (SELECT * FROM ['+ @dbname +'].dbo.sysusers WHERE name LIKE ''%'+@USER+''')' +CHAR(13)+
                    '   BEGIN' + CHAR(13) +
                    '   INSERT INTO ##users' + CHAR(13) +
                    '   SELECT name FROM ['+ @dbname +'].dbo.sysusers WHERE name LIKE ''%'+ @USER +''''+CHAR(13) +
                    '   PRINT ''USER '+ @USER +' EXISTS IN '+ @dbname +'.''' + CHAR(13) +
                    'END'
        EXEC (@SQL)
        SET @SQL = ''

        --[ CHECK FOR DB OBJECT OWNERSHIP BY THIS USER & TRANSFER OWNERSHIP TO DBO IF ]
        --[ EXISTS. ONLY APPLIES TO SQL 2005+                                         ]
        IF @version IN(9,0,1) --[ CHECK FOR SQL VERSION >= 2005                 ]
           BEGIN
           SELECT @SQL = N'USE ' + @dbname + CHAR(13) +
                          'INSERT ##Schemas (CATALOGNAME, SCHEMANAME, OBJECTNAME, OBJECTTYPE)'+CHAR(13)+
                          'SELECT [TABLE_CATALOG] [CATALOGNAME], '+CHAR(13)+
                          '       [TABLE_SCHEMA] [SCHEMANAME], '+CHAR(13)+
                          '       [TABLE_NAME] [OBJECTNAME], '+CHAR(13)+
                          '       ''VIEW'' [OBJECTTYPE] '+CHAR(13)+
                          '  FROM INFORMATION_SCHEMA.SCHEMATA A '+CHAR(13)+
                          ' INNER JOIN INFORMATION_SCHEMA.VIEWS B ON A.[SCHEMA_NAME] = B.TABLE_SCHEMA '+CHAR(13)+
                          ' WHERE SCHEMA_OWNER LIKE ''%'+ @USER +''''+CHAR(13)
           EXEC (@SQL)
           SET @SQL = ''

           SELECT @SQL = N'USE ' + @dbname + CHAR(13) +
                          'INSERT ##Schemas (CATALOGNAME, SCHEMANAME, OBJECTNAME, OBJECTTYPE)'+CHAR(13)+
                          'SELECT [SPECIFIC_CATALOG] [CATALOGNAME], '+CHAR(13)+
                          '       [SPECIFIC_SCHEMA] [SCHEMANAME], '+CHAR(13)+
                          '       SPECIFIC_NAME [OBJECTNAME], '+CHAR(13)+
                          '       ROUTINE_TYPE [OBJECTTYPE] '+CHAR(13)+
                          '  FROM INFORMATION_SCHEMA.SCHEMATA A '+CHAR(13)+
                          ' INNER JOIN INFORMATION_SCHEMA.ROUTINES B ON A.[SCHEMA_NAME] = B.SPECIFIC_SCHEMA '+CHAR(13)+
                          ' WHERE SCHEMA_OWNER LIKE ''%'+ @USER +''''+CHAR(13)
           EXEC (@SQL)
           SET @SQL = ''

           SELECT @SQL = N'USE ' + @dbname + CHAR(13) +
                          'INSERT ##Schemas (CATALOGNAME, SCHEMANAME, OBJECTNAME, OBJECTTYPE)'+CHAR(13)+
                          'SELECT CATALOG_NAME [CATALOGNAME], '+CHAR(13)+
                          '       [SCHEMA_NAME] [SCHEMANAME], '+CHAR(13)+
                          '       TABLE_NAME [OBJECTNAME], '+CHAR(13)+
                          '       ''TABLE'' [OBJECTTYPE] '+CHAR(13)+
                          '  FROM INFORMATION_SCHEMA.SCHEMATA A '+CHAR(13)+
                          ' INNER JOIN INFORMATION_SCHEMA.TABLES B ON A.[SCHEMA_NAME] = B.TABLE_SCHEMA '+CHAR(13)+
                          ' WHERE SCHEMA_OWNER LIKE ''%'+ @USER +''''+CHAR(13)
           EXEC (@SQL)
           SET @SQL = ''

           IF EXISTS(SELECT 'TRUE' FROM ##Schemas)
              BEGIN

              DECLARE crSchema CURSOR FOR
              SELECT [CATALOGNAME], [SCHEMANAME], [OBJECTTYPE], [OBJECTNAME]
                FROM ##Schemas
               ORDER BY ID

              OPEN crSchema
              FETCH NEXT FROM crSchema INTO @CATALOGNAME, @SCHEMANAME, @OBJECTTYPE, @OBJECTNAME
              WHILE @@FETCH_STATUS = 0
                    BEGIN /*[ TRANSFER DB OBJECTS FROM USER SCHEMA TO DBO SCHEMA ]*/
                    SET @SQL = N'USE ' + @dbname + CHAR(13) +
                                'ALTER SCHEMA [dbo] TRANSFER ['+ @SCHEMANAME +'].['+ @OBJECTNAME +']'+CHAR(13)+
                                'PRINT ''Transfering ownership of '+ @OBJECTTYPE +' '+ @OBJECTNAME +' to [dbo]'''
                    --EXEC (@SQL)
                    SELECT @SQL
                    SET @SQL = ''

                    FETCH NEXT FROM crSchema INTO @CATALOGNAME, @SCHEMANAME, @OBJECTTYPE, @OBJECTNAME
                END       /*[ TRANSFER DB OBJECTS FROM USER SCHEMA TO DBO SCHEMA ]*/
              CLOSE crSchema
              DEALLOCATE crSchema
           END
           ELSE
              BEGIN
              IF EXISTS(SELECT 'TRUE'
                          FROM INFORMATION_SCHEMA.SCHEMATA A
                         INNER JOIN ##users B ON B.[USER] = A.SCHEMA_OWNER)
                 SELECT @SQL = N'USE '+ @dbname + CHAR(13)+
                               'DROP SCHEMA ['+ SCHEMA_NAME +']'
                                FROM INFORMATION_SCHEMA.SCHEMATA
                               WHERE SCHEMA_OWNER LIKE '%MRHEE%'
                            
                 --EXEC (@SQL)
                 SELECT @SQL
                 SET @SQL = ''

           END
        END
TRUNCATE TABLE ##Schemas

        --[ CREATE DDL STATEMENT TO REMOVE USER.  HERE WE USE THE @version    ]
        --[ VARIABLE TO DETERMINE WHICH COMMAND TO USE                        ]
        OPEN crUser
        FETCH NEXT FROM crUser INTO @USER
        WHILE @@fetch_status = 0
              BEGIN
              IF @version IN(9,0)
                 BEGIN
                 SET @SQL = N'USE ' + @dbname + CHAR(13) +
                             'ALTER USER ['+ @USER +'] WITH DEFAULT_SCHEMA = [dbo]'+ CHAR(13) +
                             'IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'''+ @USER +''')' + CHAR(13) +
                             '    DROP SCHEMA ['+ @USER +']' + CHAR(13) +
                             'IF EXISTS (SELECT * FROM sysusers WHERE name = '''+ @USER +''')' + CHAR(13) +
                             '   BEGIN' + CHAR(13) +
                             '   DROP USER ['+ @USER +']' + CHAR(13) +
                             'PRINT ''USER '+ @USER +' has been dropped FROM '+ @dbname +'.''' + CHAR(13) +
                             'END'
              END
              ELSE
                 BEGIN
                 SET @SQL = N'USE ' + @dbname + CHAR(13) +
                             'IF EXISTS (SELECT * FROM sysusers WHERE name = '''+@USER+''')' + CHAR(13) +
                             '   BEGIN' + CHAR(13) +
                             '   EXEC sp_revokedbaccess '''+@USER+'''' + CHAR(13) +
                             'PRINT ''USER '+@USER+' has been dropped FROM '+@dbname+'.''' + CHAR(13) +
                             'END'
              END --IF
              --EXEC (@SQL)
              SELECT @SQL
              SET @SQL = ''

              FETCH NEXT FROM crUser INTO @USER
          END --WHILE
        CLOSE crUser
        FETCH NEXT FROM crDBname INTO @dbname
    END

   DEALLOCATE crUser
     CLOSE crDBname
DEALLOCATE crDBname

DROP TABLE ##users
SET @SQL = ''

OPEN crLogin
FETCH NEXT FROM crLogin INTO @login
--PRINT 'Logins = ' +@login
WHILE @@fetch_status = 0
      BEGIN
      IF EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = @login)
         SET @SQL = N'EXEC master.dbo.sp_droplogin ['+ @login +']'
         --EXEC (@SQL)
         SELECT @SQL
         SET @SQL = ''

      IF EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = @login )
         SET @SQL = N'USE master' +CHAR(13) +
                     'EXEC master.dbo.sp_revokelogin '''+ @login +'''' + CHAR(13)
         --EXEC (@SQL)
         SELECT @SQL
         SET @SQL = ''

      FETCH NEXT FROM crLogin INTO @login
  END
CLOSE crLogin
DEALLOCATE crLogin