/*-------------------------------------------------------------------------------------------------
        NAME: INDEX_Create_Clustered.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: TEMPLATE FOR THE CREATION OF A CLUSTERED INDEX. THIS TEMPLATE FORCE THE CREATION OF
              A CLUSTERED INDEX ON A HEAP TABLE
-------------------------------------------------------------------------------------------------*/
SET NOCOUNT ON

SELECT DISTINCT S.[name] [Schema]
     , O.[name] [TableName]
     , C.[name] [ColumnName]
     , C.column_id
     , T.[name] [DataType]
     , N'CREATE CLUSTERED INDEX [cix_'+ REPLACE(REPLACE(REPLACE(O.[name],' ',''),'.',''),'$','') +'__'+ C.[name] +'] ON ['+ S.[name] +'].['+ O.[name] +'] (['+ C.[name] +']) WITH (DATA_COMPRESSION=PAGE);' [IndexName]
  FROM sys.schemas S
 INNER JOIN sys.objects O ON S.[schema_id] = O.[schema_id]
 INNER JOIN sys.columns C ON O.[object_id] = C.[object_id]
 INNER JOIN sys.types T ON C.system_type_id = T.user_type_id
  LEFT JOIN sys.indexes I ON O.[object_id] = I.[object_id]
  LEFT JOIN sys.index_columns IC ON I.index_id = IC.index_id
   AND C.column_id = IC.column_id
   AND O.[object_id] = IC.[object_id]
   AND IC.column_id = 1
 WHERE O.[type] = 'U'
   AND C.column_id = 1         
   AND O.is_ms_shipped = 0
   AND I.type_desc != 'CLUSTERED'
   AND O.[name] NOT IN (SELECT DISTINCT SO.name 
                          FROM sys.indexes SI
                         INNER JOIN sys.objects SO ON SO.[object_id] = SI.[object_id]
                         WHERE SI.type_desc = 'CLUSTERED')
       