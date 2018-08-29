SELECT name
     , [type]
     , type_desc
  FROM sys.system_objects
 WHERE name LIKE 'dm_%'
 ORDER BY name