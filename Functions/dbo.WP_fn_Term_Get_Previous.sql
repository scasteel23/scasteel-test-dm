SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 7/17/2013
-- STC 9/28/17 - Return previous fall/spring term (ignore summer/winter)
CREATE FUNCTION [dbo].[WP_fn_Term_Get_Previous] 
(
	@term_cd VARCHAR(6)
)
RETURNS varchar(6)  AS  
BEGIN 
	DECLARE @prev_term_cd varchar(6)
	DECLARE @startdate DATETIME

	SELECT @startdate = TERM_START_DT
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE @term_cd = term_cd

	SELECT @prev_term_cd = term_cd
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE TERM_START_DT < @startdate
		AND TERM_TYPE_CD = 'S'
		AND TERM_CD_CAMPUS_CD = '100'
		AND RIGHT(TERM_CD, 1) IN ('1', '8')
	ORDER BY term_cd ASC

	/*
		print dbo.WP_fn_Term_Get_Previous('120158')
		print dbo.WP_fn_Term_Get_Previous('120155')
		
	*/
	RETURN @prev_term_cd
END







GO
