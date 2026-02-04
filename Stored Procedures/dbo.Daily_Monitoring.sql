SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- NS 1/18/2019 8 PM
CREATE PROC [dbo].[Daily_Monitoring]
AS
	DECLARE @Download_Datetime datetime
	DECLARE  @table_name as varchar(100) , @sqlstr varchar(1000), @printstr varchar(3000), @email_subject varchar(200)
  
	SET NOCOUNT ON
	UPDATE dbo.DM_Shadow_Monitoring_Log SET Current_Indicator = 0
	DECLARE refs  CURSOR READ_ONLY FOR
		SELECT [Table_Name]
        FROM [DM_Shadow_Staging].[dbo].[DM_Shadow_Monitoring_Reference]
		WHERE [Current_Indicator] = 1
				
	SET @printstr = ''
	OPEN refs
	FETCH refs INTO @table_name
	WHILE @@FETCH_STATUS = 0
	
	BEGIN
	 	--print @table_name
		SET @sqlstr = + ' INSERT INTO dbo.DM_Shadow_Monitoring_Log (Table_Name, Download_Datetime) '
				+ ' SELECT ''' + @table_name + ''' as Table_Name, max(Download_Datetime) as Download_Datetime '
				+ ' FROM dbo.' + @table_name 
				+ ' WHERE Download_Datetime is not NULL '
		
		--print  (@sqlstr)
		EXEC   (@sqlstr)
		FETCH refs INTO @table_name
	END

	CLOSE refs
	DEALLOCATE refs


	SELECT @printstr = COALESCE(@printstr,'','<BR>') + '<tr><td>'+ Table_Name 
			+ '</td><td>' + CONVERT(varchar,Download_Datetime,22) 
			+ '</td></tr>'	
	FROM [DM_Shadow_Staging].[dbo].[DM_Shadow_Monitoring_Log]
	where current_indicator=1
	order by Table_Name ASC

	SET @printstr = '<html><BR><BR>DM SHADOW download datetime<table>' + @printstr + '</table><html>'
	SET @email_subject = '[DM] Daily Shadow Monitoring'
	--EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu',@email_subject, @email_body
	EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu','nhadi@illinois.edu','appsmonitor@business.illinois.edu',@email_subject, @printstr

	--print @printstr

GO
