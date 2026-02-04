SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
-- NS 12/3/2018
-- Same with WP_fn_Get_Facstaff_Photo_URL
CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Photo_URL](@FSID INT)
	RETURNS VARCHAR(200)
	AS
BEGIN


	DECLARE @UPLOAD_PHOTO VARCHAR(300), @SHOW_PHOTO varchar(3)
			, @Picture_File_Path varchar(500), @USERNAME varchar(100)

	SET @UPLOAD_PHOTO = ''
	SET @SHOW_PHOTO = 'YES'
	SELECT @USERNAME = ISNULL(USERNAME,'')
			,@UPLOAD_PHOTO = ISNULL(UPLOAD_PHOTO,'') , @SHOW_PHOTO = ISNULL(SHOW_PHOTO,'YES') 
	FROM dbo._DM_PCI 
	WHERE FacstaffID = @FSID

	IF @SHOW_PHOTO = '' 
		SET @SHOW_PHOTO = 'YES'

	IF @SHOW_PHOTO = 'YES' 
		BEGIN
			IF  @UPLOAD_PHOTO <> ''
				--SET @Picture_File_Path =  @UPLOAD_PHOTO 
				SET @Picture_File_Path = "https://www3.business.illinois.edu/dmfiles/" + LTrim(RTrim(@UPLOAD_PHOTO))
	
			ELSE
				SET @Picture_File_Path = ''
		END
	ELSE
		SET @Picture_File_Path =  ''
	
	
	RETURN @Picture_File_Path

	
	--DECLARE @PhotoURL VARCHAR(255)
	--DECLARE @PhotoFile VARCHAR(100)
	--DECLARE @PhotoPath VARCHAR(200)
	--SET @PhotoURL = '' 
				
	--SELECT @PhotoFile = ISNULL(Picture_Name, ''),
	--	@PhotoPath = FSB.Network_ID + '_' + CAST(FSP.Facstaff_ID AS varchar(10)) + '/' + Picture_Name + '_resize.' + Picture_Extension
	--FROM  dbo.Facstaff_Pictures FSP
	--INNER JOIN dbo.Facstaff_Basic FSB
	--	ON FSP.Facstaff_ID = FSB.Facstaff_ID
	--WHERE FSP.Facstaff_ID = @FSID
	--	AND Picture_ID = 1
	--	AND FSP.Active_Indicator = 1
		
	--IF @PhotoFile <> ''
	--	SET @PhotoURL = 'https://www3.business.illinois.edu/fsdb2/images/faculty_photos/' + @PhotoPath

	--RETURN(@PhotoURL)
END













GO
