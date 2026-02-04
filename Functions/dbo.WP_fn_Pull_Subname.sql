SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--NS 11/28/2017
CREATE FUNCTION [dbo].[WP_fn_Pull_Subname](@nominal_subname varchar(200))
RETURNS varchar(60)
AS
BEGIN
	-- pull the actual subname from current subname, from "EDITORIAL BOARDS - Co-Editor"  to "Co-Editor"
	--		from "OTHER REVIEW - Reviewer" to "Reviewer", and so on

	DECLARE @subname varchar(60)
	IF @nominal_subname is NULL OR @nominal_subname=''
		SET @subname=''
	ELSE
		SET @subname=SUBSTRING(@nominal_subname,patindex('%-%',@nominal_subname) + 2,len(@nominal_subname) - patindex('%-%',@nominal_subname)-1)

	-- TEST
	--DECLARE @nominal_subname varchar(200)
	--SET @nominal_subname = 'EDITORIAL BOARDS - Co-Editor'
	----SET @nominal_subname = 'OTHER REVIEW - Reviewer' 
	--DECLARE @subname varchar(60)
	--print patindex('%-%',@nominal_subname) + 2
	--print len(@nominal_subname) - patindex('%-%',@nominal_subname)-1
	--SET @subname=SUBSTRING(@nominal_subname,patindex('%-%',@nominal_subname) + 2,len(@nominal_subname) - patindex('%-%',@nominal_subname)-1)
	--print @subname

	RETURN @subname
END


GO
