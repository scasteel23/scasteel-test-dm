SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 6/2/2016
CREATE PROC [dbo].[_Test_USERS_produce_XML]
AS


	
	SELECT 
		1 AS TAG,
		NULL AS PARENT,
		USERS.username  AS [Record!1!username],
		NULL AS [USERS!2!FirstName!ELEMENT],
		NULL AS [USERS!2!MiddleName!ELEMENT],
		NULL AS [USERS!2!LastName!ELEMENT],
		NULL AS [USERS!2!Email!ELEMENT],
		NULL AS [USERS!2!enabled!ELEMENT],
		NULL AS [USERS!2!UIN!ELEMENT],
		NULL AS [USERS!2!ShibbolethAuthentication!ELEMENT]

	FROM dbo.Users AS USERS
	WHERE    Load_Scope='Y'

	UNION ALL

	SELECT 
		2 AS TAG,
		1 AS PARENT,
		USERS.username,
		USERS.First_Name,
		USERS.Middle_Name,
		USERS.Last_Name,
		USERS.Email_Address,
		USERS.Enabled_Indicator,
		USERS.UIN,
		''

	FROM dbo.USERS 
	WHERE    Load_Scope='Y'
	ORDER BY [Record!1!username]

	FOR XML  EXPLICIT,ROOT('Data')



GO
