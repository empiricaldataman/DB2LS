/*
-------------------------------------------------------------------------------------------------
        NAME: INDEX_Table_Without_Cluster.sql
 MODIFIED BY: Sal Young
       EMAIL: saleyoun@yahoo.com
 DESCRIPTION: 
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			        killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------
*/

WITH CTE1 
  AS (SELECT S.[name] [Schema]
           , O.[name] [TableName]
             --, I.[name] [IndexName]
             --, C.[name] [ColumnName]
             --, C.column_id
             --, T.[name] [DataType]
             --, IC.*
        FROM sys.schemas S
       INNER JOIN sys.objects O ON S.[schema_id] = O.[schema_id]
       INNER JOIN sys.columns C ON O.[object_id] = C.[object_id]
       INNER JOIN sys.types T ON C.system_type_id = T.system_type_id
        LEFT JOIN sys.indexes I ON O.[object_id] = I.[object_id]
        LEFT JOIN sys.index_columns IC ON I.index_id = IC.index_id
         AND C.column_id = IC.column_id
         AND O.[object_id] = IC.[object_id]
       WHERE O.[type] = 'U'
         AND I.type_desc = 'CLUSTERED'),
     CTE2
  AS (SELECT A.name
        FROM sys.objects A
        LEFT JOIN CTE1 B ON A.[name] = B.[TableName]
       WHERE B.TableName IS NULL
         AND A.[type] = 'U')

SELECT * 
  FROM CTE2

   


--SELECT N'CREATE CLUSTERED INDEX idx_'+ O.[name] +'_'+ C.[name] +' ON ['+ s.[name] +'].['+ o.[name] +'] ('+ c.[name] +') WITH (DATA_COMPRESSION = PAGE)'+ CHAR(10) +'GO'+ CHAR(10)
--        FROM sys.schemas S
--       INNER JOIN sys.objects O ON S.[schema_id] = O.[schema_id]
--       INNER JOIN sys.columns C ON O.[object_id] = C.[object_id]
--       INNER JOIN sys.types T ON C.system_type_id = T.system_type_id
--        LEFT JOIN sys.indexes I ON O.[object_id] = I.[object_id]
--        LEFT JOIN sys.index_columns IC ON I.index_id = IC.index_id
--         AND C.column_id = IC.column_id
--         AND O.[object_id] = IC.[object_id]
--       WHERE O.[type] = 'U'
--         AND O.[name] IN ('QA_29_1204','cmdb_ci_pn','MKH_Loan_Borrower_Process_III','QA_4','GC1','AnnualActivityDefinitionStg','Monitoring_Metric_Grain_Management','NG_27','Application_Vehicle_Dim_bkp_12042012_prod','QA_12_1204','Loss_Forecast_Score_Portfolio_Group_Lookup','NG_16','Event_Last_Call_Old','NG_3','QA_31','QA_18','gary_events','AnnualActivityDefinitionStg1','QA_30','NG_30','NG_31','QA_18_1204','QA_6','Event_First_Call_Old','PS_CM','QA_28','QA_15','NG_6','NG_18','QA_11_1204','call_sam_temp','NG_2','MKH_Loan_Borrower_Del','PS_Loan_Base','u_asset_archive','QA_3','Loan_Portfolio_Monthly_Fact_Curr_bkp_12042012_prod','fc_Loan_Modification_7day','LoanBaseDay_Hist_Progress_Run1','u_effort_master','fc_modification_set_code','MKH_Loan_Borrower_Process','fc_Loan_rewrite','QA_19_1204','NG_5','Loan_Activity_Definition_Detail_12Dec2012','tt','Applicant_Dim_bkp_12042012_prod','Loan_Portfolio_Gl_Monthly_Fact_Curr_bkp_12042012_prod','Information_Security_Administrator_1213','GT_Min_recommendation','QA_5_1204','cmdb_ci','fc_Loan_rewrite_7day','Information_Security_Secureid_1213','QA_10_1204','QA_1_1204','NG_9','Application_bkp_12042012_prod','QA_3_1204','LBS_2','CTR2','segmentation','ServiceNow_Staging_Metadata_20121130','QA_6_1204','Application_Cars_recommendation','GT_MAX_recommendation','NG_13','QA_28_1204','QA_99','u_effort_type','t_vw_cmdb_ci_monitor','CTR1','QA_2','QA_11','QA_20','Loan_Activity_Definition_12Dec2012','lb','Asset_Type_Dim_07December2012','NG_15','QA_27_1204','QA_10','sys_user_Driver','QA_1','QA_97','QA_15_1204','QA_16_1204','QA_17_1204','DailyActivityDefinition','NG_28','PS_LB','sys_user','QA_14_1204','MM_Runs','NG_12','ServiceNow_Staging_Metadata_20121121','NG_17','Event_Sandbox_Old','NG_98','ServiceNow_Staging_Metadata_20121104','PS_PM','Loan_Base_Day_2010_Run2','LFBMF_Load_Status','Information_Security_Metric_1213','LoanBaseDay_Hist_Progress','NG_19','QA_20_1204','NG_1','db_logical_database_server_PS','cars_recommendations','Application_Funding_Credit_Policy_Exception_History','LoanBaseDay_Hist_Progress_Run2','NG_99','MKH_Loan_Borrower_Process_II','QA_98','NG_10','NG_11','NG_97','QA_5','Loan_Base_Day_2010_Run1','LoanBaseDay_Hist_Progress_test','Asset_Type_Dim_29November2012','AnnualActivityDefinitionStg1_New','Application_Dim_ETL_bkp_12042012_prod','NG_14','NG_29','QA_16','QA_19','cmdb_ci_monitor','QA_17','Cmdb_Ci_Temp_12_04_2012','QA_9_1204','pari_events','QA_2_1204','QA_4_1204','Application_Delta_bkp_12042012_prod','AnnualActivityDefinitionStg1_Old','QA_13','NG_4','QA_27','PS_LM','QA_9','PS_LP','ETL_Control','gt_test','QA_12','QA_13_1204','cmdb_ci_appl_05_december_2012','QA_29','NG_20','credit_recommendations','QA_14','u_effort_floor_location')
--         AND c.column_id = 1