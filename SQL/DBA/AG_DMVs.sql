/*
-------------------------------------------------------------------------------------------------
        NAME: AG_DMVs.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: USE THESE QUERIES TO REVIEW ALL CONFIGURATION DETAILS ABOUT AVAILABILITY GROUPS
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SELECT * FROM sys.availability_databases_cluster
SELECT * FROM sys.availability_group_listener_ip_addresses
SELECT * FROM sys.availability_group_listeners
SELECT * FROM sys.availability_groups
SELECT * FROM sys.availability_groups_cluster
SELECT * FROM sys.availability_read_only_routing_lists
SELECT * FROM sys.availability_replicas
