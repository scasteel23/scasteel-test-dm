SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- STC 3/30/20 - Get current AC_YEAR record for each DM user

CREATE FUNCTION [dbo].[DM_fn_Get_AC_YEAR] ()
RETURNS @Temps 
		TABLE(
				uin bigint,
				userid bigint,
			    username varchar(60),
				AC_YEAR varchar(12)
		) 
AS
BEGIN
	DECLARE @cur_ac_year varchar(9)

	SELECT @cur_ac_year = dbo.BUS_fn_Get_AC_YEAR(CURRENT_TIMESTAMP)

	INSERT INTO @Temps
	SELECT distinct 
		[UIN]
		,u.[userid]
		,u.[username]
		,AC_YEAR
	from _DM_USERS u
	inner join _DM_ADMIN a
		on u.userid = a.userid
	where not exists (
		select *
		from _DM_ADMIN a2
		where a2.userid = u.userid
			and a2.AC_YEAR > a.AC_YEAR
			and a2.AC_YEAR <= @cur_ac_year
		)
		and a.AC_YEAR <= @cur_ac_year 
	order by u.username	

	RETURN 
END
GO
