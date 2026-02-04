SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2017
CREATE FUNCTION [dbo].[Get_Term_Year] 
(
	@term_cd VARCHAR(6)
)
RETURNS varchar(10)  AS  
BEGIN 
	
	DECLARE @term_year VARCHAR(10)

	IF @term_cd IS NULL OR @term_cd = ''
		SET @term_year = ''
	ELSE
		SET @term_year = RIGHT(LEFT(@term_cd,5),4)

	--SELECT @startdate = TERM_START_DT
	--FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	--WHERE @term_cd = term_cd

	/*
		print dbo.Get_Term_Year('120158')
		print dbo.Get_Term_Year('120155')
		
	*/
	RETURN @term_year
END






GO
