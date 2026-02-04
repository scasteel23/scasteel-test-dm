SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 Rewritten for DM (11 years later...)
-- NS 9/20/2007 for OUTLOOK directory (maintained by Steve Hess), derived from OUTLOOK_fn_Get_Display_Name_By_FSID

CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Display_Name_No_Middle_Name_By_FSID] (@facstaff_id int)
RETURNS varchar(60) AS  
BEGIN 

DECLARE @FullName  varchar(60)
DECLARE @PERS_PREFERRED_FName varchar(35)
DECLARE @Professional_Last_Name varchar(35)
DECLARE @First_Name varchar(35)
DECLARE @Last_Name varchar(35)

/*
PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(290)
	PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(292)
	PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(11995)
*/

SELECT @PERS_PREFERRED_FName = isnull(PFNAME,''),
	@Professional_Last_Name = isnull(PLNAME,''),
	@First_Name = isnull(FName,''),
	@Last_Name = isnull(LName,'')
FROM dbo._DM_PCI FB
 WHERE  FB.facstaffid = @facstaff_id


SET @PERS_PREFERRED_FName= rtrim(ltrim(@PERS_PREFERRED_FName))

SET @Professional_Last_Name= rtrim(ltrim(@Professional_Last_Name))
SET @First_Name= rtrim(ltrim(@First_Name))
SET @Last_Name= rtrim(ltrim(@Last_Name))

SET  @FullName = CASE 
 	WHEN	(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' +
		@PERS_PREFERRED_FNAME  ) 

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND  
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name  + ', ' +	@First_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 	
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName )

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND  
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name)

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName  )

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' +  @First_Name )

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @First_Name)

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName )

	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName )
		
	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 	
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name )
		

	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 	
		(Len(@Professional_Last_Name) = 0 OR @Professional_Last_Name IS NULL) THEN 
		(@Last_Name + ', ' + @PERS_PREFERRED_FName )
		
	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) = 0 OR @PERS_PREFERRED_FName IS NULL) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @First_Name)
		
	 WHEN (Len(@First_Name) = 0 OR @First_Name IS NULL) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN 
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName)
		
	 WHEN (Len(@First_Name) <> 0) AND 
		(Len(@PERS_PREFERRED_FName) <> 0) AND 
		(Len(@Professional_Last_Name) <> 0) THEN  
		(@Professional_Last_Name + ', ' + @PERS_PREFERRED_FName)

	 ELSE @Last_Name END


RETURN @FullName

END

















GO
