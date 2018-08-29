/*-------------------------------------------------------------------------------------------------
        NAME: CMD_TYPE.sql
  CREATED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Displays the contents of one or more text files using SQLCMD mode
-------------------------------------------------------------------------------------------------
-- TR/PROJ#   DATE        MODIFIED      DESCRIPTION   
-------------------------------------------------------------------------------------------------
-- F000000    07.21.2016  SYoung        Initial creation.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------*/
:setvar vPATH "'<full_file_path, sysname, File path>'"

:!!type $(vPATH)



