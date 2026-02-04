SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 2/12/2007  for College (web) Directory and OUTLOOK Directory , derived from Web_FSD_sp_Get_Faculty_All
-- NS 9/20.2007 no longer used, replaced by OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID and OUTLOOK_fn_Get_Display_Name_No_Middle_Name_By_FSID

CREATE FUNCTION [dbo].[OUTLOOK_fn_Get_Display_Name_By_FSID] (@facstaff_id int)
RETURNS varchar(60) AS  
BEGIN 

DECLARE @FullName  varchar(60)
DECLARE @PERS_PREFERRED_FName varchar(35)
DECLARE @Middle_Name varchar(35)
DECLARE @Professional_Last_Name varchar(35)
DECLARE @First_Name varchar(35)
DECLARE @Last_Name varchar(35)

SELECT @PERS_PREFERRED_FName = isnull(PERS_PREFERRED_FName,''),
	@Middle_Name = isnull(Middle_Name, ''),
	@Professional_Last_Name = isnull(Professional_Last_Name,''),
	@First_Name = isnull(First_Name,''),
	@Last_Name = isnull(Last_Name,'')
FROM   dbo.Facstaff_Basic FB
WHERE  @facstaff_id = FB.facstaff_id

SET @PERS_PREFERRED_FName= rtrim(ltrim(@PERS_PREFERRED_FName))
SET @Middle_Name= rtrim(ltrim(@Middle_Name))
SET @Professional_Last_Name= rtrim(ltrim(@Professional_Last_Name))
SET @First_Name= rtrim(ltrim(@First_Name))
SET @Last_Name= rtrim(ltrim(@Last_Name))

SET  @FullName = CASE 
 	WHEN	(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' +
		@PERS_PREFERRED_FNAME  + ' ' +
		@Middle_Name ) 

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND  
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name  + ', ' +
		@First_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName )

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND  
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @Middle_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name)

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName  )

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' +  @First_Name )

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @First_Name)
		

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName  + ' ' +
		@Middle_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName )
		

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @Middle_Name)
		

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName  + ' ' +
		@Middle_Name)
		

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @First_Name  + ' ' +
		@Middle_Name)

		

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName  + ' ' + 
		@Middle_Name)
		
	
	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Middle_Name) = 0 OR @Middle_Name IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN  
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName)
		

	 ELSE @Last_Name END


RETURN @FullName

END

















GO
