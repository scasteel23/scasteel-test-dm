SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/27/2017
CREATE PROC [dbo].[DailyUpdate_sp_DM_Step12_Manual_Error_Inspection]

AS

 DECLARE @current_datetime as datetime, @current_date varchar(12)
 SET @current_datetime=getdate()
 SET @current_date = convert(varchar, @current_datetime,101)
 --print @current_date
 
 /*
	SELECT [webservices_logs_id], load_status_cd as err, What_Loaded
		,[LOAD_STATUS_DESC], [POST_DATE]
	FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
	ORDER BY POST_DATE DESC

	SELECT * FROM [DM_Shadow_Staging].[dbo].[webservices_requests] ORDER BY created DESC

 */
  SELECT [webservices_logs_id], load_status_cd as err, REPLACE([What_Loaded],'/login/service/v4/UserSchema/USERNAME:','') as Network_ID
	,[LOAD_STATUS_DESC], [POST_DATE]
  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
  where load_status_cd = '400' --and [webservices_logs_id]>2824
	AND [POST_DATE] >= @current_date
	AND What_loaded LIKE '%/login/service/v4/UserSchema/USERNAME:%'

  UNION

  SELECT  [webservices_logs_id], load_status_cd as err, [What_Loaded] as Network_ID
	,[LOAD_STATUS_DESC], [POST_DATE]
  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
  where load_status_cd = '400' --and [webservices_logs_id]>2824
	AND [POST_DATE] >= @current_date
	AND What_loaded NOT LIKE '%/login/service/v4/UserSchema/USERNAME:%'
	--AND What_loaded LIKE '%/login/service/v4/UserSchema/USERNAME:%'

  UNION

  SELECT  [webservices_logs_id], load_status_cd as err, [What_Loaded] as Network_ID
	,[LOAD_STATUS_DESC], [POST_DATE]
  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
  where load_status_cd = '500' --and [webservices_logs_id]>2824
	AND [POST_DATE] >= @current_date

  order by  [webservices_logs_id] asc

GO
