SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/22/2017
CREATE FUNCTION [dbo].[Get_Term_Fullname] 
(
	@term_cd VARCHAR(6)
)
RETURNS varchar(10)  AS  
BEGIN 
	
	DECLARE @term_name VARCHAR(100)
	DECLARE @term_id varchar(1)

	SELECT @term_name = Term_Name
	FROM dbo.DM_Term_Codes
	WHERE Term_Code = @term_cd

	IF @term_name IS NULL 
		SET @term_name = ''
	


	/*
		print dbo.Get_Term_FullName('120158')
		print dbo.Get_Term_FullName('120155')
		
	*/
	RETURN @term_name
END






GO
