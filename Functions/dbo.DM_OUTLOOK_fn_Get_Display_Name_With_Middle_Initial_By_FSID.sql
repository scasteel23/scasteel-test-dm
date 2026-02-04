SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 Rewritten for DM (11 years later...)
-- NS 9/20/2007 for College Directory Information, derived from OUTLOOK_fn_Get_Display_Name_By_FSID
-- STC 2/26/15 - Do not show Middle Initial when value starts with '('
--				 (Parentheses are commonly used in this field to display an alternate (American) first name)

CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID] (@facstaff_id int)
RETURNS varchar(60) AS  
BEGIN 

/*
	PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(290)
	PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(292)
	PRINT dbo.OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(11995)

*/

DECLARE @FullName  varchar(60)
DECLARE @PFNAME varchar(35)
DECLARE @MNAME varchar(35)
DECLARE @PLNAME varchar(35)
DECLARE @FNAME varchar(35)
DECLARE @LNAME varchar(35)

SELECT @PFNAME = isnull(PFNAME,''),
	@MNAME = isnull(MNAME, ''),
	@PLNAME = isnull(PLNAME,''),
	@FNAME = isnull(FNAME,''),
	@LNAME = isnull(LNAME,'')
FROM   dbo._DM_PCI FB
WHERE  @facstaff_id = FB.facstaffid

SET @PFNAME= rtrim(ltrim(@PFNAME))
SET @MNAME= rtrim(ltrim(@MNAME))
IF @MNAME <> ''
	SET @MNAME= LEFT(@MNAME,1) + '.'
IF @MNAME = '(.'
	SET @MNAME = ''

SET @PLNAME= rtrim(ltrim(@PLNAME))
SET @FNAME= rtrim(ltrim(@FNAME))
SET @LNAME= rtrim(ltrim(@LNAME))

SET  @FullName = CASE 
 	WHEN	(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' +
		@PFNAME  + ' ' +
		@MNAME ) 

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND  
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME  + ', ' +
		@FNAME)

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' + @PFNAME )

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND  
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' + @MNAME)

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME)

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' + @PFNAME  )

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' +  @FNAME + ' ' + @MNAME )

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' + @FNAME)
		

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' + @PFNAME  + ' ' +
		@MNAME)

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' + @PFNAME )
		

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' + @MNAME)
		

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) = 0 OR @PLNAME IS NULL) THEN 
		(@LNAME + ', ' + @PFNAME  + ' ' +
		@MNAME)
		

	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) = 0 OR @PFNAME IS NULL) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' + @FNAME  + ' ' +
		@MNAME)

		

	 WHEN (Len(@FNAME) = 0 OR @FNAME IS NULL) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) <> 0) AND 
		(Len(@PLNAME) <> 0) THEN 
		(@PLNAME + ', ' + @PFNAME  + ' ' + 
		@MNAME)
		
	
	 WHEN (Len(@FNAME) <> 0) AND 
		(Len(@PFNAME) <> 0) AND 
		(Len(@MNAME) = 0 OR @MNAME IS NULL) AND 
		(Len(@PLNAME) <> 0) THEN  
		(@PLNAME + ', ' + @PFNAME)
		

	 ELSE @LNAME END


RETURN @FullName

END


















GO
