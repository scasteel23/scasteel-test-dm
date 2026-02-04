SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- NS 12/5/2018: rewritten/renamed for DM
--KA: June 2014: Used in SP: [dbo].[WP_XML_People_Directory]
--The above Stored procedure uses an array of deptcode in a variable that has to be passed to the IN clause. 
--Since the variable has deptcodes seperated by commas, we cannot use it directly in the IN clause. We need to parse the string first and then use it.

CREATE FUNCTION [dbo].[WP_fn_Parse_String_To_Table] 
(
		@query_string varchar(2000)
) 
	RETURNS @Depts TABLE(code int) AS
		BEGIN
		DECLARE @pos int
		SET @pos=CHARINDEX(',',@query_string)
		WHILE @pos>0
			 BEGIN
			 INSERT @Depts(code) SELECT LEFT(@query_string,CHARINDEX(',',@query_string)-1)
			 SET @query_string = SUBSTRING(@query_string,CHARINDEX(',',@query_string)+1,LEN(@query_string))
			 SET @pos=CHARINDEX(',',@query_string)
			 END
		IF LEN(@query_string)>0
			 BEGIN
			 INSERT @Depts(code) SELECT @query_string
			 END
		RETURN 
		END

/*

DECLARE @query_string VARCHAR(300)
set @query_string = '1,2,3,4,5,8'
select * from Faculty_staff_Holder.dbo.WP_Parse_String_To_Table(@query_string) 
where code in (8)

*/
GO
