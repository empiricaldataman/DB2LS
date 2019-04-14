/*
-------------------------------------------------------------------------------------------------
        NAME: SB_ContractsDetail.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: DISPLAYS SB CONTRACTS AND MESSAGES METADATA
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
              killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/
SELECT C.[name] [contract]
     , M.[name] [message_type]
     , CASE WHEN is_sent_by_initiator = 1 AND is_sent_by_target = 1 THEN 'ANY'     
            WHEN is_sent_by_initiator = 1 THEN 'INITIATOR'     
            WHEN is_sent_by_target    = 1 THEN 'TARGET' END [sent_by] 
  FROM sys.service_message_types AS M   
 INNER JOIN sys.service_contract_message_usages AS U ON M.message_type_id = U.message_type_id   
 INNER JOIN sys.service_contracts AS C ON C.service_contract_id = U.service_contract_id 
 ORDER BY C.[name], M.[name];