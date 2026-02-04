SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS: 7/21/2016
CREATE FUNCTION [dbo].[DailyUpdate_fn_Get_DM_Ethnicity] (@ethnicity_code varchar(2)) 
RETURNS varchar(50) AS  
BEGIN 
	DECLARE @sname varchar(50)
	
	SELECT @sname = RACE_ETH_DESC
	FROM dbo.DM_Ethnicity_Codes PETRECH 
	WHERE RACE_ETH_CD = @ethnicity_code AND RACE_ETH_CD_CUR_INFO_IND = 'Y' 

	IF @sname is NULL
		SET @sname = ''

	RETURN @sname
	
END


GO
