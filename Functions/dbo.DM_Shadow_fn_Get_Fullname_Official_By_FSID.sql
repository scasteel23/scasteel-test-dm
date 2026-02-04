SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 10/25/2017
-- NS 11/9/2006 for list of faculty, derived from [OUTLOOK_fn_Get_Fullname_Official_By_FSID]

CREATE FUNCTION [dbo].[DM_Shadow_fn_Get_Fullname_Official_By_FSID] (@facstaff_id int)
RETURNS varchar(60) AS  
BEGIN 

DECLARE @FullName  varchar(60)

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
 WHERE  FB.FACSTAFFID = @facstaff_id

RETURN @FullName

END




GO
