SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[Compose_Fullname]
(
	@lname varchar(30),
	@fname varchar(30),
	@mname varchar(30)
)

RETURNS varchar(60) AS  
BEGIN 
	DECLARE @fullname varchar(60)
	
	SET @fullname = ''
   	IF @fname IS NOT NULL AND @mname IS NOT NULL 
		 SET @fullname = @lname  + ', ' + @fname + ' ' +  @mname
	ELSE
	    IF @fname Is NOT NULL AND @mname IS NULL 
		SET @fullname = @lname + ', ' + @fname
	    ELSE 
	         IF @fname IS NULL AND @mname IS NOT NULL 
		 SET @fullname = @lname + ', ' +  @mname
	         ELSE 
		 SET @fullname = @lname 

	RETURN @fullname
END



GO
