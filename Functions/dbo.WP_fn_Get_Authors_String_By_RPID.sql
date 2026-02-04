SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 11/29/2017 rewritten
--		Pubications in _DM_INTELLCONT are identified by [ID]
--		that match [ID] in _DM_INTELLCONT_AUTH

--KA: Modified: Sep 2014: Used in Profile page
--Original function: [dbo].[Adhoc_sp_Get_Authors_String_By_RPID]

-- STC 4/14/15
--	Fixed error in failing to append to existing string when adding new 
--		adding new Business author
--  Only trim author string if non-empty
--  Remove 'FSRP.Active_Indicator = 1' from WHERE clause -- return all authors.

CREATE     FUNCTION [dbo].[WP_fn_Get_Authors_String_By_RPID](@ID INT)
	RETURNS VARCHAR(8000)
AS
	BEGIN


	--	PRINT dbo.[WP_fn_Get_Authors_String_By_ID_1] (239, '144216225792')
		DECLARE @FSID AS VARCHAR(100)
		DECLARE @S INT
		DECLARE @LName AS VARCHAR(120)
		DECLARE @FName AS VARCHAR(120)
		DECLARE @MName AS VARCHAR(130) 
		DECLARE @BPI AS VARCHAR(1) 
		DECLARE @AII AS VARCHAR(1) 
		DECLARE @AuthorString AS VARCHAR(MAX)
		DECLARE @WebsiteURL AS VARCHAR(100)
		DECLARE @SomeID VARCHAR(500)

		SET @AuthorString = ''

		SET @WebsiteURL = dbo.WP_fn_Get_Website_Prefix('College Faculty Profile')
	
		-- STC 5/12/11 - Removed 'FSRP.Active_Indicator = 1' from WHERE clause.  We want to return all authors.

		DECLARE FSRP_Authors  CURSOR SCROLL FOR 
		SELECT ISNULL(P.FACSTAFFID,0) AS Fasctaff_ID
			  ,IA.sequence 
			  ,IA.FNAME as First_Name
			  ,IA.LNAME as Last_Name
			  ,IA.MNAME as Middle_Name
			  --,CASE WHEN IA.FACULTY_NAME <> '' THEN '1'
					--ELSE '0' END AS BUS_Person_Indicator  
			  ,CASE WHEN P.ACTIVE IS NOT NULL  THEN '1'
				ELSE '0' END AS BUS_Person_Indicator  
			  --,IA.INSTITUTION
			  --,IA.WEB_PROFILE
			   ,CASE WHEN P.ACTIVE = 'Yes' THEN '1'
					ELSE '0' END AS Active_Indicator  
		  	
		FROM dbo._DM_INTELLCONT_AUTH IA
				LEFT OUTER JOIN dbo._DM_PCI P
				ON IA.FACULTY_NAME = P.userid
		WHERE IA.id= @id
		ORDER BY IA.sequence ASC

		--SELECT		FSRP.Facstaff_ID, FSRP.[Sequence], FSB.First_Name, 
		--			FSB.PERS_Preferred_FName, FSB.Last_Name, 
		--			FSB.Professional_Last_Name, FSB.BUS_Person_Indicator, 
		--			FSB.Active_Indicator 
		--FROM		Facstaff_Research_Publications FSRP  
		--				INNER JOIN Facstaff_Basic FSB 
		--					ON FSRP.Facstaff_ID = FSB.Facstaff_ID 
		--WHERE		FSRP.Research_Publication_ID = @RPID
		--ORDER BY	FSRP.[Sequence] ASC 

		OPEN FSRP_Authors
		FETCH FSRP_Authors INTO @FSID, @S, @FName, @LName, @MName, @BPI, @AII
	
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- Start of FSRP_Authors 
		IF @FSID IS NOT NULL -- Start of @FSID NOT NULL 
			BEGIN 				
					
				IF @BPI = '1' AND @AII = '1' -- Active BUS PErson
					BEGIN 		
						--KA: Get someID (canonical name for profile) from FSID
						SET @SomeID = dbo.WP_fn_Get_SomeID_from_FSID (@FSID)	
						IF @LName IS NOT NULL OR Len(@LName) <> 0
							BEGIN
								--SET @AuthorString = @AuthorString + '<A HREF=Faculty_Profile.aspx?ID=' + @FSID + '>' +   @PLName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
								SET @AuthorString = @AuthorString + '<A HREF=''/profile/' + @SomeID + '''>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
					
							END
							ELSE
							BEGIN
								--SET @AuthorString = @AuthorString + '<A HREF=Faculty_Profile.aspx?ID=' + @FSID + '>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
								SET @AuthorString = @AuthorString + '<A HREF=''/profile/' + @SomeID + '''>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
							END				
					END
				ELSE IF @BPI = '0' OR (@BPI = '1' AND @AII = '0') -- NON-BUS Person
					BEGIN
						SET @AuthorString = @AuthorString + @LName + ', ' + LEFT(@FName, 1) + '., '
					END				
			
				/* get the next record from FSRP_Authors */
				FETCH FSRP_Authors INTO @FSID, @S, @FName, @LName, @MName, @BPI,@AII

			END -- End of @FSID NOT NULL 
		END -- End of FSRP_Authors
		
		/* Close FSRP_Authors */
		CLOSE FSRP_Authors
		DEALLOCATE FSRP_Authors	

		-- STC 5/12/11 - Only trim if string is non-empty
		IF @AuthorString <> ''
			SET @AuthorString = Left(@AuthorString, (Len(@AuthorString) - 1))
	
		RETURN @AuthorString
	END

/*
	DECLARE @FSID AS VARCHAR(100) 
	DECLARE @S INT
	DECLARE @LName AS VARCHAR(100)
	DECLARE @PLName AS VARCHAR(100) 
	DECLARE @FName AS VARCHAR(100)
	DECLARE @PFName AS VARCHAR(100) 
	DECLARE @BPI AS VARCHAR(1) 
	DECLARE @AII AS VARCHAR(1) 
	DECLARE @AuthorString AS VARCHAR(8000)

	SET @AuthorString = ''
							
	-- STC 4/14/15 - Removed 'FSRP.Active_Indicator = 1' from WHERE clause.  We want to return all authors.
	DECLARE		FSRP_Authors  CURSOR SCROLL FOR 
	SELECT		FSRP.Facstaff_ID, FSRP.[Sequence], FSB.First_Name, 
				FSB.PERS_Preferred_FName, FSB.Last_Name, 
				FSB.Professional_Last_Name, FSB.BUS_Person_Indicator, 
				FSB.Active_Indicator 
	FROM		Facstaff_Research_Publications FSRP  
				INNER JOIN Facstaff_Basic FSB ON FSRP.Facstaff_ID = FSB.Facstaff_ID 
	WHERE		FSRP.Research_Publication_ID = @RPID
	ORDER BY	 FSRP.[Sequence] ASC 

	OPEN FSRP_Authors
	FETCH FSRP_Authors INTO @FSID, @S, @FName, @PFName, @LName, @PLName, @BPI, @AII   

	WHILE @@FETCH_STATUS = 0 
	BEGIN -- Start of FSRP_Authors 
	IF @FSID IS NOT NULL -- Start of @FSID NOT NULL 
		BEGIN 
			DECLARE @SomeID VARCHAR(500)	
			SET @SomeID = Faculty_staff_Holder.dbo.WP_fn_Get_SomeID_from_FSID (@FSID)	
			
			IF @BPI = 1 AND @AII = 1 -- Active BUS Person
			BEGIN 		
				
				IF @PLName IS NOT NULL OR Len(@PLName) <> 0
				BEGIN
					--SET @AuthorString = @AuthorString + '<A HREF=Faculty_Profile.aspx?ID=' + @FSID + '>' +   @PLName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
					SET @AuthorString = @AuthorString + '<A HREF=/profile/' + @SomeID + '>' +   @PLName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
					
				END
				ELSE
				BEGIN
					--SET @AuthorString = @AuthorString + '<A HREF=Faculty_Profile.aspx?ID=' + @FSID + '>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
					SET @AuthorString = @AuthorString + '<A HREF=/profile/' + @SomeID + '>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
				END									
			END
			ELSE IF @BPI = 0 OR (@BPI = 1 AND @AII = 0) -- NON-BUS Person
			BEGIN
				SET @AuthorString = @AuthorString + @LName + ', ' + LEFT(@FName, 1) + '., '
			END			
			
			/* get the next record from FSRP_Authors */
			FETCH FSRP_Authors INTO @FSID, @S, @FName, @PFName, @LName, @PLName, @BPI, @AII   

						
		END -- End of @FSID NOT NULL 
	END -- End of FSRP_Authors

		
	/* Close FSRP_Authors */
	CLOSE FSRP_Authors
	DEALLOCATE FSRP_Authors	

	-- STC 4/14/15 - Only trim if string is non-empty
	--RETURN(Left(@AuthorString, (Len(@AuthorString) - 1)))

	IF @AuthorString <> ''
		SET @AuthorString = Left(@AuthorString, (Len(@AuthorString) - 1))

	RETURN @AuthorString
END

*/
GO
