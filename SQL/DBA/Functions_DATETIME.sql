
SELECT CAST(GETDATE() AS time) [time]                                                   --Defines a time of a day. The time is without time zone awareness and is based on a 24-hour clock.
     , CAST(GETDATE() AS date) [date]                                                   --Defines a date in SQL Server.
     , CAST(GETDATE() AS smalldatetime) [smalldatetime]                                 --Defines a date that is combined with a time of day. The time is based on a 24-hour day, with seconds always zero (:00) and without fractional seconds.
     , CAST(GETDATE() AS datetime) [datetime]                                           --Defines a date that is combined with a time of day with fractional seconds that is based on a 24-hour clock.
     , CAST(GETDATE() AS datetime2) [datetime2]                                         --Defines a date that is combined with a time of day that is based on 24-hour clock. datetime2 can be considered as an extension of the existing datetime type that has a larger date range, a larger default fractional precision, and optional user-specified precision.
     , CAST(GETDATE() AS datetimeoffset) [datetimeoffset]                               --Defines a date that is combined with a time of a day that has time zone awareness and is based on a 24-hour clock.
     , SYSDATETIME() [SYSDATETIME]                                                      --Returns a datetime2(7) value that contains the date and time of the computer on which the instance of SQL Server is running. The time zone offset is not included.
     , SYSDATETIMEOFFSET() [SYSDATETIMEOFFSET]                                          --Returns a datetimeoffset(7) value that contains the date and time of the computer on which the instance of SQL Server is running. The time zone offset is included.
     , SYSUTCDATETIME() [SYSUTCDATETIME]                                                --Returns a datetime2(7) value that contains the date and time of the computer on which the instance of SQL Server is running. The date and time is returned as UTC time (Coordinated Universal Time).
     , CURRENT_TIMESTAMP [CURRENT_TIMESTAMP]                                            --Returns a datetime value that contains the date and time of the computer on which the instance of SQL Server is running. The time zone offset is not included.
     , GETDATE() [GETDATE]                                                              --Returns a datetime value that contains the date and time of the computer on which the instance of SQL Server is running. The time zone offset is not included.
     , GETUTCDATE() [GETUTCDATE]                                                        --Returns a datetime value that contains the date and time of the computer on which the instance of SQL Server is running. The date and time is returned as UTC time (Coordinated Universal Time).
     , DATENAME(DW,GETDATE()) [DATENAME]                                                --Returns a character string that represents the specified datepart of the specified date.
     , DATEPART(DAYOFYEAR,GETDATE()) [DATEPART]                                         --Returns an integer that represents the specified datepart of the specified date.
     , DAY(GETDATE()) [DAY]                                                             --Returns an integer that represents the day day part of the specified date.
     , MONTH(GETDATE()) [MONTH]                                                         --Returns an integer that represents the month part of a specified date.
     , YEAR(GETDATE()) [YEAR]                                                           --Returns an integer that represents the year part of a specified date.
     , DATEFROMPARTS(2016,07,01) [DATEFROMPARTS]                                        --Returns a date value for the specified year, month, and day.
     , DATETIME2FROMPARTS(2016,07,01,12,00,00,00,7) [DATETIME2FROMPARTS]                --Returns a datetime2 value for the specified date and time and with the specified precision.
     , DATETIMEFROMPARTS(2016,07,01,12,00,00,00) [DATETIMEFROMPARTS]                    --Returns a datetime value for the specified date and time.
     , DATETIMEOFFSETFROMPARTS(2016,07,01,12,00,00,00,-1,0,0) [DATETIMEOFFSETFROMPARTS] --Returns a datetimeoffset value for the specified date and time and with the specified offsets and precision.
     , SMALLDATETIMEFROMPARTS(2016,07,01,12,00) [SMALLDATETIMEFROMPARTS]                --Returns a smalldatetime value for the specified date and time.
     , TIMEFROMPARTS(12,0,0,0,0) [TIMEFROMPARTS]                                        --Returns a time value for the specified time and with the specified precision.
     , DATEDIFF(DD,'20160101',GETDATE()) [DATEDIFF]
     --, DATEDIFF_BIG(DD,'20160101',GETDATE()) [DATEDIFF_BIG]
     , DATEADD(DD,5,GETDATE()) [DATEADD]
     , EOMONTH(GETDATE()) [EOMONTH]
     , SWITCHOFFSET() [SWITCHOFFSET]
     --, TODATETIMEOFFSET [TODATETIMEOFFSET]
     --, @@DATEFIRST [@@DATEFIRST]
     --, ISDATE(GETDATE()) [ISDATE]
