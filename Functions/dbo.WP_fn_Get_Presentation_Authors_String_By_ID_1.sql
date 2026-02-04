SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 11/30/2017: Based on  WP_fn_Get_Authors_String_By_ID_1, this sp is for _DM_PRESENT_AUTH table

CREATE     FUNCTION [dbo].[WP_fn_Get_Presentation_Authors_String_By_ID_1](@FSID1 INT, @ID BIGINT)
RETURNS VARCHAR(MAX)
AS
BEGIN


	--	PRINT dbo.WP_fn_Get_Presentation_Authors_String_By_ID_1 (239, '134053957632')
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
		  	
	FROM dbo._DM_PRESENT_AUTH IA
			LEFT OUTER JOIN dbo._DM_PCI P
			ON IA.FACULTY_NAME = P.userid
	WHERE IA.id= @id
	ORDER BY IA.WEB_PROFILE_ORDER ASC

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
					IF @FSID1 = @FSID 
						BEGIN 		
							SET @AuthorString = @AuthorString + @LName + ', ' + LEFT(@FName, 1) +'., '
						END
					ELSE
						BEGIN
							--SET @AuthorString = @AuthorString + '<A HREF=' + @WebsiteURL + '/Faculty_Profile.aspx?ID=' + @FSID + '>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '
							SET @AuthorString =  @AuthorString + '<A HREF=/profile/' + @SomeID + '>' +   @LName + ', ' + LEFT(@FName, 1) +'.</A> ' + ', '					
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


GO
