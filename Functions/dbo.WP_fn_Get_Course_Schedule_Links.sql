SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



--NS: 3/17/2015: Changed the course website, added @CRS_Subject parameter, handled 'all' argument for @TERM_CD
--KA: 10/2014
CREATE FUNCTION [dbo].[WP_fn_Get_Course_Schedule_Links]
(
	@CRS_Subject VARCHAR(6),
	@CRS_NBR VARCHAR(6),
	@TERM_CD VARCHAR(10)  -- 'all' for showing all course terms/schedules
)
RETURNS varchar(800)
AS

	-- https://courses.illinois.edu/schedule/terms/ACCY/199
	BEGIN
		DECLARE @courseURLString varchar(800), @term_name varchar(60)
        
		SET @CRS_Subject = upper(@CRS_Subject)
--=================================================
	--KA: Set @SourceURLString
			--07 Oct 2014: Update after checking with Scott: Since we observed some discrepencies, For now, do NOT go to 
			--schedule page. Just lead all courses to catalog page. Once the issue is resolved with the individual departments, 
			--then visit back and uncomment the below section.
			
					  -- If @TERM_CD <= @latest_term 
							--BEGIN
							--	SET @SourceURLString = '/schedule/'
							--END
					  -- Else 					
							--BEGIN
							--	SET @TERM_CD = @latest_term
							--	SET @SourceURLString = '/catalog/'
							--END
								
--======================================================
	--KA: Set Term name
	IF @TERM_CD = 'all'
		BEGIN
			SET	@courseURLString = 'http://courses.illinois.edu/schedule/terms/' + @CRS_Subject + '/' + @CRS_NBR
		END
	ELSE
		BEGIN
			  If RIGHT(@TERM_CD,1) = '1' 
				   BEGIN
						SET @term_name = 'spring'
				   END
			  Else IF RIGHT(@TERM_CD,1) = '5' 
				   BEGIN
						SET @term_name = 'summer'
				   END
			   Else IF RIGHT(@TERM_CD,1) = '8' 
				   BEGIN
						SET @term_name = 'fall'
				   END
			   Else
				   BEGIN
						SET @term_name = ''
				   END
		
			--KA: Set Base URl string
				SET	@courseURLString = 'https://courses.illinois.edu/schedule/' + substring(@TERM_CD, 2,4) + '/' + @term_name + '/' + @CRS_Subject + '/' + @CRS_NBR
		
				
		END
	

			RETURN @courseURLString
END


--SELECT [dbo].[WP_fn_Get_Course_Schedule_Links]('badm', '403', '120151')
--SELECT [dbo].[WP_fn_Get_Course_Schedule_Links]('accy', '304', '120158')
--SELECT [dbo].[WP_fn_Get_Course_Schedule_Links]('badm', '320', 'all')

--OLDS
--http://courses.illinois.edu/cis/2014/fall/schedule/BADM/320.html
--http://courses.illinois.edu/cis/2014/spring/schedule/BADM/539.html
--http://courses.illinois.edu/cis/2014/fall/catalog/BADM/320.html

-- NEW:
--https://courses.illinois.edu/schedule/2015/spring/ACCY/304
--https://courses.illinois.edu/schedule/terms/ACCY/202


GO
