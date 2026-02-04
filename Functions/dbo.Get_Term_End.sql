SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2017
CREATE FUNCTION [dbo].[Get_Term_End] 
(
	@term_cd VARCHAR(6)
)
RETURNS varchar(30)  AS  
BEGIN 
	
	DECLARE @startdate VARCHAR(30)
	DECLARE @startdatetime datetime

	SELECT @startdatetime = TERM_END_DT
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE @term_cd = term_cd

	IF @startdatetime IS NULL
		SET @startdate = ''
	ELSE
		SET @startdate=LEFT(convert(varchar,@startdatetime,127),10)
	/*
		print dbo.Get_Term_End('120158')
		print dbo.Get_Term_End('120155')
		
	*/
	RETURN @startdate
END






GO
