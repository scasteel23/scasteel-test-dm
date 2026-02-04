SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- STC 3/30/20 - Get string of DM titles for each DM user
-- uses '+' as delimiter between titles

-- select * from dbo.DM_fn_Get_All_Employee_Titles()

CREATE FUNCTION [dbo].[DM_fn_Get_All_Employee_Titles] ()
RETURNS @Temps 
		TABLE(
			    username varchar(60),
				userid bigint,
				uin bigint,
				EDWPERSID bigint,
				titles varchar(5000)
		) 
AS
BEGIN
	INSERT INTO @Temps
	SELECT 
		[username]
		,[userid]
		,[UIN]
		,[EDWPERSID]
		,isnull((
			select stuff((
				select ' + ' + t.TITLE
				from _dm_users u2
				inner join DM_AC_YEAR_View a
					on u2.userid = a.userid
				inner join _DM_ADMIN_TITLE t
					on t.AC_YEAR = a.AC_YEAR
						and t.userid = a.userid
				where t.TITLE_CURRENT = 'Yes'
					and u2.userid = u.userid
				order by t.SEQ
				FOR XML PATH(''),TYPE
			).value('.','varchar(max)'), 1, 3, '')
		),'') as Titles
	FROM [DM_Shadow_Staging].[dbo]._DM_USERS u
	ORDER BY username	

	RETURN 
END
GO
