SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




-- NS 4/30/2007
CREATE FUNCTION [dbo].[WP_fn_Term_Get_Current]
(
	@todaysdate datetime
)
RETURNS varchar(6)  AS  
BEGIN 
	DECLARE @term_cd varchar(6)

	SELECT @term_cd = term_cd
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE @todaysdate < TERM_END_DT 
		AND TERM_TYPE_CD = 'S'
		AND TERM_CD_CAMPUS_CD = '100'
	ORDER BY term_cd desc

	RETURN @term_cd
END








GO
