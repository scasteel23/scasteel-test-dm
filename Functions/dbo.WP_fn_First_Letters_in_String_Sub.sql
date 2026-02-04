SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



--KA: Sep 2014
--Used in: [dbo].[WP_fn_first_letters_in_string] 

CREATE FUNCTION [dbo].[WP_fn_First_Letters_in_String_Sub] ( @str NVARCHAR(4000), @num_of_char int )
RETURNS NVARCHAR(2000)
AS
BEGIN
    DECLARE @retval NVARCHAR(2000);

    SET @str=RTRIM(LTRIM(@str));
    SET @retval=LEFT(@str,@num_of_char);

    WHILE CHARINDEX(' ',@str,@num_of_char)>0 BEGIN
        SET @str=LTRIM(RIGHT(@str,LEN(@str)-CHARINDEX(' ',@str,@num_of_char)));
        SET @retval+=LEFT(@str,@num_of_char);
    END
    
     RETURN @retval;
END


/*
SELECT dbo.WP_fn_first_letters_in_string2('Commission Auditors')
SELECT dbo.WP_fn_first_letters_in_string2('International Journal')
SELECT dbo.WP_fn_first_letters_in_string2('Regulation')

*/

GO
