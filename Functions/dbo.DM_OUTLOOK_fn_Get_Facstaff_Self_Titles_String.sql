SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 rewritten for DM
-- NS 2/16/2007
-- Originals from Report_FSD_fn_Get_Titles_String_By_FSID

-- STC 5/4/17 -- Removed extra white space, no substantive changes made

CREATE       FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Self_Titles_String](@FSID INT, @EMPEE_GROUP_CD varchar(4))
	RETURNS VARCHAR(8000)
	AS
BEGIN

		-- print dbo.DM_OUTLOOK_fn_Get_Facstaff_Self_Titles_String(90,'staff')
		DECLARE @TitleString VARCHAR(8000) 
		DECLARE @TitleName VARCHAR(200) , @seq INT
		DECLARE @group VARCHAR(4), @ac_year varchar(10), @cdate datetime, @threhold_date varchar(12), @current_ac_year varchar(10)

		
		SET @TitleString = '' 
		SET @TitleName = '' 
	
		-- >>>> GET THE proper AC_YEAR
		SET @cdate = GETDATE()
		SET @threhold_date = '8/16/' + CAST(YEAR(GETDATE())AS VARCHAR)
		IF @cdate >= @threhold_date
			SET @current_ac_year = CAST(YEAR(GETDATE())AS VARCHAR) + '-' + CAST(YEAR(GETDATE())+1 AS VARCHAR)
		ELSE
			SET @current_ac_year = CAST(YEAR(GETDATE())-1AS VARCHAR) + '-' + CAST(YEAR(GETDATE()) AS VARCHAR)
		--print @current_ac_year

		-- Get the earliest year between current year and the farthest future year
		SELECT @ac_year=min(ac_year)
		FROM dbo._DM_ADMIN_TITLE
		WHERE facstaffid = @FSID 
				AND ac_year >= @current_ac_year

		IF @ac_year is NULL
			SELECT @ac_year=max(ac_year)
			FROM dbo._DM_ADMIN_TITLE
			WHERE facstaffid = @FSID 
					AND ac_year < @current_ac_year
		-- >>>> GET THE TITLES

		IF @ac_year is NOT NULL
			BEGIN
				
				DECLARE FST_Titles  CURSOR SCROLL FOR 
					SELECT distinct TITLE as Title_Name   , seq
					FROM dbo._DM_ADMIN_TITLE   
					WHERE facstaffid = @FSID AND ac_year = @ac_year
					ORDER BY SEQ

				OPEN FST_Titles
				FETCH FST_Titles INTO @TitleName , @seq
		
				WHILE @@FETCH_STATUS = 0 
				BEGIN -- Start of FST_Titles Cursor
				IF @TitleName IS NOT NULL -- Start of @TitleName NOT NULL 
					BEGIN 
						IF @TitleString = '' -- Cursor is at the First Record 
						BEGIN
							SET @TitleString = @TitleName  					
						END
						ELSE -- Cursor is not at the First Record 
						BEGIN
							SET @TitleString = @TitleString + ' and ' + @TitleName
						END
											
						/* get the next record from FST_Titles */
						FETCH FST_Titles INTO @TitleName, @seq
							
					END -- End of @TitleName NOT NULL 
				END -- End of FST_Titles Cursor

				/* Close FST_Titles */
				CLOSE FST_Titles
				DEALLOCATE FST_Titles	
			END
			 	
		
		IF (@TitleString is NULL OR RTRIM(@TitleString) = '') AND  @EMPEE_GROUP_CD IS NOT NULL
		     BEGIN
				SET @group = RTRIM(@EMPEE_GROUP_CD)
				IF @group = 'H'
					SET @TitleString = 'Academic/Graduate Hourly'
				ELSE
				IF @group = 'G'
					SET @TitleString = 'Graduate Assistant'
				ELSE
				IF @group = 'S'
					SET  @TitleString = 'Undergraduate Hourly'
		     END
	
		

		SET @TitleString = REPLACE(@TitleString, '&', 'and')

		RETURN(@TitleString)
	END
GO
