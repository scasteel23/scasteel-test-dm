SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 11/30/2017

CREATE  FUNCTION [dbo].[WP_fn_Compose_Conference_Name]
(
	@Conference_Name varchar(200)
	,@Conference_City varchar(100)
	,@Conference_State varchar(100)
	,@Conference_Country varchar(100)
)
RETURNS varchar(200)  AS  
BEGIN 

	DECLARE @comma varchar(2)
	DECLARE @Name varchar(400)

	SET @Conference_Name = ISNULL(@Conference_Name,'N/A')
	SET @Conference_City = ISNULL(@Conference_City,'N/A')
	SET @Conference_State = ISNULL(@Conference_State,'N/A')
	SET @Conference_Country = ISNULL(@Conference_Country,'N/A')

	SET @comma = ''
	
	IF @Conference_Name <> ''
		BEGIN
			IF @Conference_City <> 'N/A' AND @Conference_City <> ''
				BEGIN
					SET @Name = @name + @comma + @Conference_City
					SET @comma = ', '
				END
			IF @Conference_State <> 'N/A' AND @Conference_State <> ''
				BEGIN
					SET @Name = @name + @comma + @Conference_State
					SET @comma = ', '
				END
			IF @Conference_Country <> 'N/A' AND @Conference_Country <> ''
				BEGIN
					SET @Name = @name + @comma + @Conference_Country
					SET @comma = ', '
				END
		END

	
	
	RETURN @name
END







GO
