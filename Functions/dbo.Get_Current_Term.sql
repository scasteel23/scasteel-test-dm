SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



-- NS 4/4/2017
CREATE  FUNCTION [dbo].[Get_Current_Term]
(
	@todaysdate datetime
)
RETURNS varchar(6)  AS  
BEGIN 
	DECLARE @term_cd varchar(6)

	SELECT @term_cd = term_cd
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE @todaysdate < term_end_dt and RIGHT(term_cd, 1) <> '7'
	ORDER BY term_cd desc

	RETURN @term_cd
END


GO
