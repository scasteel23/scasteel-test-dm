SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



--NS: 3/17/2015: Similar to [WP_fn_Get_Course_Schedule_Links]
CREATE FUNCTION [dbo].[WP_fn_Get_Course_Catalog_Links]
(
	@CRS_Subject VARCHAR(6),
	@CRS_NBR VARCHAR(6)
)
RETURNS varchar(800)
AS

	BEGIN
		-- http://catalog.illinois.edu/search/?P=ACCY%20592
		DECLARE @courseURLString varchar(800), @term_name varchar(60)
        
		SET @CRS_Subject = upper(@CRS_Subject)

		SET	@courseURLString = 'https://courses.illinois.edu/schedule/terms/' + @CRS_Subject + '/' + @CRS_NBR
	
		RETURN @courseURLString
	END


--SELECT [dbo].[WP_fn_Get_Course_Catalog_Links]('badm', '403')
--SELECT [dbo].[WP_fn_Get_Course_Catalog_Links]('accy', '304')
--SELECT [dbo].[WP_fn_Get_Course_Catalog_Links]('badm', '320')



GO
