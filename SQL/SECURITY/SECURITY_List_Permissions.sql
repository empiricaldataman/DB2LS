SET NOCOUNT ON
;
WITH CTE1 ([Grantor], [GrantorIs], [Grantee], [GranteeIs], [PermissionGranted], [Schema], major_id, minor_id, [Object], [ObjectType], [IsMemberOfDBRole], [Level])
  AS (SELECT p1.[name] [Grantor]
           , p1.type_desc [GrantorIs]
           , p2.[name] [Grantee]
           , p2.type_desc [GranteeIs]
           , p3.[permission_name] [PermissionGranted]
           , s1.[name] [Schema]
           , p3.major_id
           , p3.minor_id
           , o1.[name] [Object]
           , o1.type_desc [ObjectType]
           , p4.[name] [IsMemberOfDBRole]
           , 0 [Level]
        FROM sys.database_principals p1
       INNER JOIN sys.database_permissions p3 ON p1.principal_id = p3.grantor_principal_id
       INNER JOIN sys.database_principals p2 ON p3.grantee_principal_id = p2.principal_id
       INNER JOIN sys.schemas s1 ON p1.principal_id = s1.principal_id
        LEFT JOIN sys.database_role_members r1 ON p2.principal_id = r1.member_principal_id
        LEFT JOIN sys.database_principals p4 ON r1.role_principal_id = p4.principal_id
        LEFT JOIN sys.objects o1 ON p3.major_id = o1.[object_id]
       WHERE p4.[name] IS NULL --p2.[name] = 'BROWER\SQL_ETL_DataDeveloper'
       UNION ALL
       SELECT p1.[name] [Grantor]
           , p1.type_desc [GrantorIs]
           , p2.[name] [Grantee]
           , p2.type_desc [GranteeIs]
           , p3.[permission_name] [PermissionGranted]
           , s1.[name] [Schema]
           , p3.major_id
           , p3.minor_id
           , o1.[name] [Object]
           , o1.type_desc [ObjectType]
           , p4.[name] [IsMemberOfDBRole]
           , Level + 1 [Level]
        FROM sys.database_principals p1
       INNER JOIN sys.database_permissions p3 ON p1.principal_id = p3.grantor_principal_id
       INNER JOIN sys.database_principals p2 ON p3.grantee_principal_id = p2.principal_id
       INNER JOIN sys.schemas s1 ON p1.principal_id = s1.principal_id
       INNER JOIN sys.database_role_members r1 ON p2.principal_id = r1.member_principal_id
       INNER JOIN sys.database_principals p4 ON r1.role_principal_id = p4.principal_id
       INNER JOIN CTE1 ON p4.[name] = CTE1.Grantee
       INNER JOIN sys.objects o1 ON p3.major_id = o1.[object_id])

SELECT * FROM CTE1




