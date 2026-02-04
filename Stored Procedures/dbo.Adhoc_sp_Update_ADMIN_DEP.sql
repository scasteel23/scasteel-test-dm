SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 6/21/2019
CREATE PROC [dbo].[Adhoc_sp_Update_ADMIN_DEP]
AS
select * 
into #temptemp
from _upload_dm_users

SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #Updates
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST((SELECT '2018-2019' AC_YEAR		
		,(
			SELECT DEP, '1' as SHOW_DIRECTORY				
			FROM #temptemp d WHERE d.username = c.username
			FOR XML PATH('ADMIN_DEP'),TYPE
		 ) 
		 FROM #temptemp c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM #temptemp c 
	) x;

	INSERT INTO webservices_requests(method,url,post,process)
	--OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL
GO
