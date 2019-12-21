/*
-------------------------------------------------------------------------------------------------
        NAME: SECURITY_CREATE_DB_USER.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: Use these statements to create AZ database users, assign it to db roles and 
              create database firewall rules.
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
--[ CREATE DATABASE USER ON Azure SQL DATABASE

--[ BASED ON DOMAIN\GroupName
CREATE USER [GroupName] FROM EXTERNAL PROVIDER

--[ BASED ON SQL LOGIN WITH PASSWORD]
CREATE USER [sql_loginName] WITH PASSWORD '<>';

--[ ADD TO dbo_owner DATABASE ROLE
ALTER ROLE db_owner ADD MEMBER GroupName

--[ REVIEW CURRENT DATABASE FIREWALL RULES
SELECT * FROM sys.database_firewall_rules

--[ ADD IPs TO FIREWALL 
EXECUTE sp_set_database_firewall_rule @name = N'Description', @start_ip_address = '1.1.1.0', @end_ip_address = '1.1.1.255'
EXECUTE sp_set_database_firewall_rule @name = N'Description 2', @start_ip_address = '0.0.0.0', @end_ip_address = '0.0.0.255'