SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2017
CREATE FUNCTION [dbo].[Get_Term_Name] 
(
	@term_cd VARCHAR(6)
)
RETURNS varchar(10)  AS  
BEGIN 
	
	DECLARE @term_name VARCHAR(10)
	DECLARE @term_id varchar(1)

	IF @term_cd IS NULL OR @term_cd = ''
		SET @term_name = ''
	ELSE
		BEGIN 
			SET @term_id = RIGHT(@term_cd,1)
	
			SET @term_name = CASE @term_id
				WHEN '1' THEN 'Spring'
				WHEN '8' THEN 'Fall'
				WHEN '0' THEN 'Winter'
				WHEN '5' THEN 'Summer'
				ELSE ''
			END
		END



	/*
		print dbo.Get_Term_Name('120158')
		print dbo.Get_Term_Name('120155')
		
	*/
	RETURN @term_name
END






GO
