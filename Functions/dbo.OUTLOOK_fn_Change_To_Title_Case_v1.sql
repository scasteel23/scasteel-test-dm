SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 2/16/2007
CREATE FUNCTION [dbo].[OUTLOOK_fn_Change_To_Title_Case_v1](@input VARCHAR(4000)) RETURNS VARCHAR(4000)
AS 
BEGIN
	-- http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=37760, kselvia, 07/21/2004
	DECLARE @position INT
	WHILE IsNull(@position,Len(@input)) > 1
	SELECT @input = Stuff(@input,IsNull(@position,1),1,upper(substring(@input,IsNull(@position,1),1))), 
		@position = charindex(' ',@input,IsNull(@position,1)) + 1
	RETURN (@input)
END


GO
