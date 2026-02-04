SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 1/9/2019 : rewritten to return RANKS (of strings) instead of RANK_ID (of integers)
-- NS 12/5/2018: rewritten/renamed for DM
--KA: June 2014: Used in SP: [dbo].[WP_XML_People_Directory]
--The above Stored procedure uses an array of deptcode in a variable that has to be passed to the IN clause. 
--Since the variable has deptcodes seperated by commas, we cannot use it directly in the IN clause. We need to parse the string first and then use it.

CREATE FUNCTION [dbo].[WP_fn_Parse_String_To_Table_Of_Ranks] 
(
		@query_string varchar(2000)
) 
	RETURNS @Depts TABLE(ranks varchar(100)) AS
	BEGIN
		DECLARE @pos int
		DECLARE @iDepts TABLE(code varchar(100))
		SET @pos=CHARINDEX(',',@query_string)
		WHILE @pos>0
			BEGIN
				INSERT @iDepts(code) 
				SELECT LEFT(@query_string,CHARINDEX(',',@query_string)-1)
				SET @query_string = SUBSTRING(@query_string,CHARINDEX(',',@query_string)+1,LEN(@query_string))
				SET @pos=CHARINDEX(',',@query_string)
			END
		IF LEN(@query_string)>0
			BEGIN
				INSERT @iDepts(code) SELECT @query_string
			END
		INSERT INTO @Depts(ranks)
		SELECT r2.Rank_Description FROM @iDEpts r1 INNER JOIN DM_Shadow_Staging.dbo.FSDB_Rank_Codes r2 ON r1.code = r2.Rank_ID
		RETURN 
	END

/*

DECLARE @query_string VARCHAR(300)
set @query_string = '1,2,3,4,5,8'

select * from DM_Shadow_STaging.dbo.[WP_fn_Parse_String_To_Table_Of_String](@query_string) 
select * from DM_Shadow_STaging.dbo.[WP_fn_Parse_String_To_Table](@query_string) 
where code in (8)

*/
GO
