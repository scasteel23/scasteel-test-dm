SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 Rewritten for DM (12 years later...)
-- NS 11/9/2006 for list of faculty, derived from Web_FSD_sp_Get_Faculty_All

CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Fullname_Official_By_FSID] (@facstaff_id int)
RETURNS varchar(60) AS  
BEGIN 

DECLARE @FullName  varchar(60)
/*
	PRINT dbo.OUTLOOK_fn_Get_Fullname_Official_By_FSID(290)
	PRINT dbo.OUTLOOK_fn_Get_Fullname_Official_By_FSID(292)

*/
 SELECT  @FullName = CASE 
 	WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.PFNAME  + ' ' +
		FB.MNAME + ' ' +
		FB.PLNAME) 

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND  
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.FNAME  + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.PFNAME  + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND  
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.MNAME  + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.PLNAME)

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.PFNAME  + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.FNAME  + ' ' + 
		FB.MNAME + ' ' +  
		FB.LNAME)

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.FNAME  + ' ' +
		FB.PLNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.PFNAME  + ' ' +
		FB.MNAME + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.PFNAME  + ' ' +
		FB.PLNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.MNAME + ' ' +
		FB.PLNAME)

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) = 0 OR FB.PLNAME IS NULL) THEN 
		(FB.PFNAME  + ' ' +
		FB.MNAME + ' ' +
		FB.LNAME)

	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) = 0 OR FB.PFNAME IS NULL) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.FNAME  + ' ' +
		FB.MNAME + ' ' + 

		FB.PLNAME)

	 WHEN (Len(FB.FNAME) = 0 OR FB.FNAME IS NULL) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) <> 0) AND 
		(Len(FB.PLNAME) <> 0) THEN 
		(FB.PFNAME  + ' ' + 
		FB.MNAME + ' ' + 
		FB.PLNAME)
	
	 WHEN (Len(FB.FNAME) <> 0) AND 
		(Len(FB.PFNAME) <> 0) AND 
		(Len(FB.MNAME) = 0 OR FB.MNAME IS NULL) AND 
		(Len(FB.PLNAME) <> 0) THEN  
		(FB.PFNAME  + ' ' + 
		FB.PLNAME)

	 ELSE FB.LNAME END

 FROM dbo._DM_PCI FB
 WHERE  FB.facstaffid = @facstaff_id

RETURN @FullName

END





GO
