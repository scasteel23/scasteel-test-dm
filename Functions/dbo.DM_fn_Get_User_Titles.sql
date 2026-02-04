SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- STC 3/30/20 - Get string of DM titles for specified user
-- uses '+' as delimiter between titles

-- select dbo.DM_fn_Get_Titles_By_Username('scasteel')

CREATE FUNCTION [dbo].[DM_fn_Get_User_Titles]
(
	@Username	varchar(60)
)
RETURNS varchar(5000) 
AS
BEGIN
	DECLARE @titles varchar(5000)

	SELECT @titles = isnull((
			select stuff((
				select ' + ' + t.TITLE
				from _dm_users u2
				inner join _DM_ADMIN a
					on u2.userid = a.userid
				inner join _DM_ADMIN_TITLE t
					on t.AC_YEAR = a.AC_YEAR
						and t.userid = a.userid
				where t.TITLE_CURRENT = 'Yes'
					and u2.EDWPERSID = u.EDWPERSID
					and u2.Enabled_Indicator = 1
					and not exists (
						SELECT *
						FROM _DM_ADMIN a2
						WHERE a2.userid = a.userid
							AND a2.AC_YEAR > a.AC_YEAR
						)
				order by t.SEQ
				FOR XML PATH(''),TYPE
			).value('.','varchar(max)'), 1, 3, '')
		),'')
	FROM [DM_Shadow_Staging].[dbo]._DM_USERS u
	where u.username = @Username

	RETURN @titles
END
GO
