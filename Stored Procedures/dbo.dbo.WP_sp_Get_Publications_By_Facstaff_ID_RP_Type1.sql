SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



-- NS 11/20/2017: rewritten
--		Simplify [WP_sp_Get_Publications_By_Facstaff_ID_RP_Type1] and [WP_sp_Get_Publications_By_Facstaff_ID_RP_Type2]
--		Into [WP_sp_Get_Publications_By_Facstaff_ID]
--		Called in WP2_People_Profile.aspx.vb
--		original dbo.[WP_sp_Get_Publications_By_Facstaff_ID_RP_Type1] 239,, "IN (1, 6, 7, 9)"
--		new dbo.[WP_sp_Get_Publications_By_Facstaff_ID] 239, "('Article in Journal','Book','Monograph','Chapter in a Book')", 2
-- STC 6/7/11
--		Added Publication_Status field for sorting
--			Sort with Forthcoming (Accepted/Under contract) first, Published second
--			(Previously was sorting as: Accepted, Published, Under contract)

--KA: Modified: Sep 2014: Changed journal string function

-- STC 4/1/15 -- Add check for FSRP.Active_Indicator <> 0

-- EXEC dbo.WP_sp_Get_Publications_By_Facstaff_ID 239, "('Article in Journal','Book','Monograph','Chapter in a Book')", 2
-- EXEC dbo.WP_sp_Get_Publications_By_Facstaff_ID 239, "('Article in Journal','Book','Monograph','Chapter in a Book')", 0

CREATE PROC [dbo].[dbo.WP_sp_Get_Publications_By_Facstaff_ID_RP_Type1]
(
	@Facstaff_ID INT 
	,@Research_Publication_Types VARCHAR(1000)
	,@Past_Year INT		-- @Past_Year=0 is all years, @Past_Year > 0 is the last @Past_Year years
)
AS

	--SELECT  dbo.WP_fn_Get_Authors_String_By_FSID_RPID1(FSRP.Facstaff_ID, RP.Research_Publication_ID) AS Authors, 
	--	FSRP.Facstaff_ID, RP.*, 
	--	dbo.WP_fn_Get_Journal_URL_By_RPID(RP.Research_Publication_ID) AS Journal_Name,
	
	--	RPT.Research_Publication_Name, RPST.Research_Publication_Sub_Name, 
	--	SC.Scope_Name, P.Publisher_Name, C.Conference_Name, PIC.Publication_Issue_Name, 
	--	BR.Book_Role_Name, RPCT.Research_Publication_Contribution_Name,  P.Publisher_Location, 
	--	Publication_Status = CASE
	--		WHEN RP.Research_Publication_Status_Indicator IN ('A', 'U') THEN 'Forthcoming'
	--		ELSE 'Published' END

	-- cannot map yet
	-- 
	--	RPYear = CASE
	--		WHEN RP.Published_Year IS NOT NULL THEN (RP.Published_Year)
	--		WHEN RP.Accepted_Year Is NOT NULL THEN (RP.Accepted_Year)
	--		ELSE RP.[Year] END,
	DECLARE @checkYear varchar(3)
	SET @checkYear = 'Yes'
	IF @Past_Year = 0
		BEGIN
			SET @Past_Year = 100 -- actually no need to change
			SET @checkYear = 'No'
		END

	SELECT dbo.WP_fn_Get_Authors_String_By_ItemID(IA.ItemID) AS Authors
	  ,I.Research_Publication_ID
	  ,U.FacstaffID as Facstaff_ID
	  ,CASE  
			WHEN 	CONTYPE='Article in a Journal' THEN 1
			WHEN 	CONTYPE='Conference Proceeding' THEN 2
			WHEN 	CONTYPE='Presentation' THEN 3
			WHEN 	CONTYPE='Working Paper' THEN 4
			WHEN 	CONTYPE='Instructional Software' THEN 5
			WHEN 	CONTYPE='Book' THEN 6
			WHEN 	CONTYPE='Monograph' THEN 7
			WHEN 	CONTYPE='Manual / Guide' THEN 8
			WHEN 	CONTYPE='Chapter in a Book' THEN 9
			WHEN 	CONTYPE='Case Study' THEN 10
			ELSE 11
		END
		AS Research_Publication_Type
	  ,I.TITLE as  Research_Publication_Title
	  ,I.TITLE_SECONDARY as Sub_Title
	  --[Research_Publication_Contribution_Type]
	 
	  ,I.id as INTELLCONT_ID
      ,I.Research_Publication_ID
      ,I.CLASSIFICATION as Research_Publication_Sub_Name
	  ,CASE WHEN I.CONTYPE='Other' THEN ISNULL(I.CONTYPEOTHER,'Other') 
			ELSE I.CONTYPE END as Research_Publication_Name
      ,I.ARTICLE_TYPE
      
      
      ,I.[STATUS] as Publication_Status
	  ,CASE I.[STATUS] 
					WHEN 'Published' Then 'R'
					WHEN 'Accepted' Then 'A'
					WHEN 'Under Contract' Then 'U' 
					WHEN 'Published' Then  	'P'
					ELSE '' END as Research_Publication_Status_Indicator
      ,I.JOURNAL_REF
      ,I.JOURNAL_ID
      ,I.JOURNAL_NAME as Journal_Name
      ,I.JOURNAL_REFEREED
      ,I.JOURNAL_REVIEW_TYPE
      ,I.CONFERENCE as Conference_Name
      ,I.PUBLISHER as Publisher_Name
      ,I.PUBCTYST as Publisher_Location
      ,I.VOLUME as Volume
      ,I.ISSUE as Publication_Issue_Name
      ,I.PAGENUM as Research_Publication_Pages
	  
	  -- SEE Faculty_Staff_Holder.dbo.[__DM_Excel_INTELLCONT]

      
	  ,CASE WHEN I.REVISED = 'Yes' THEN 1 ELSE 0 END as [Revision_Indicator]
      ,CASE WHEN I.INVITED = 'Yes' THEN 1 ELSE 0 END as [Invited_Indicator]
	  ,CASE WHEN I.UNDER_REVIEW = 'Yes' THEN 1 ELSE 0 END as [Under_Review_Indicator]
      ,RPYear = CASE
			WHEN I.DTM_PUB IS NOT NULL AND I.DTM_PUB <> '' THEN I.DTM_PUB   
			ELSE I.DTY_ACC END
      ,I.EDITORS as Editor
      ,I.DTM_PREP
      ,I.DTY_PREP
      ,I.DTM_EXPSUB
      ,I.DTD_EXPSUB
      ,I.DTY_EXPSUB
      ,I.DTM_SUB
      ,I.DTD_SUB
      ,I.DTY_SUB
      ,I.DTM_ACC
      ,I.DTY_ACC as Accepted_Year
      ,I.DTM_PUB
      ,I.DTD_PUB
      ,I.DTY_PUB as Published_Year
      ,I.[DESC] as [Research_Publication_Description]
      ,I.SCOPE_LOCALE as Scope_Name
      ,I.PUBLICAVAIL
      ,I.PROCEEDING_TYPE
      ,I.ABSTRACT
      ,I.WEB_ADDRESS
      ,I.SSRN_ID
      ,I.DOI
      ,I.ISBNISSN
      ,I.Missing_Google_ID
      ,I.Missing_Book_Role
      ,I.Missing_PERENNIAL
	  
	--INTO #tempPub2
	FROM dbo._DM_INTELLCONT I 
		INNER JOIN dbo._DM_INTELLCONT_AUTH IA 
			INNER JOIN dbo._DM_USERS U
			ON U.userid = IA.FACULTY_NAME
		ON I.id = IA.id
	WHERE U.FACSTAFFID = @Facstaff_ID
			AND I.CONTYPE IN (SELECT item FROM dbo.WP_fn_Parse_CSV (@Research_Publication_Types,','))
			AND IA.WEB_PROFILE='Yes'
			AND ( ((@checkYear = 'Yes') AND (I.DTY_ACC >= ((SELECT DATEPART(YEAR, GETDATE()) - @Past_Year)) 
						OR I.DTY_PUB >= ((SELECT DATEPART(YEAR, GETDATE())- @Past_Year))) ) 
				OR (@checkYear = 'No') )
	


	-- EXEC dbo.WP_sp_Get_Publications_By_Facstaff_ID_RP_Type1 1, ''
	-- EXEC dbo.WP_sp_Get_Publications_By_Facstaff_ID_RP_Type1 239, ''
/*

	DECLARE @Research_Publication_Types varchar(1000)
	SET @Research_Publication_Types ='''Article in Journal'',''Book'',''Monograph'',''Chapter in a Book'''
	SELECT * FROM dbo.WP_fn_Parse_CSV (@Research_Publication_Types,',')

DECLARE @SQLString as VARCHAR(8000)

SET @SQLString = 
	'SELECT DISTINCT dbo.WP_fn_Get_Authors_String_By_FSID_RPID1(FSRP.Facstaff_ID, RP.Research_Publication_ID) AS Authors, 
		FSRP.Facstaff_ID, RP.*, 
		dbo.WP_fn_Get_Journal_URL_By_RPID(RP.Research_Publication_ID) AS Journal_Name,
		RPYear = CASE
			WHEN RP.Published_Year IS NOT NULL THEN (RP.Published_Year)
			WHEN RP.Accepted_Year Is NOT NULL THEN (RP.Accepted_Year)
			ELSE RP.[Year END,
		RPT.Research_Publication_Name, RPST.Research_Publication_Sub_Name, 
		SC.Scope_Name, P.Publisher_Name, P.Publisher_Location, C.Conference_Name, PIC.Publication_Issue_Name, 
		BR.Book_Role_Name, RPCT.Research_Publication_Contribution_Name,  
		Publication_Status = CASE
			WHEN RP.Research_Publication_Status_Indicator IN (''A'', ''U'') THEN ''Forthcoming''
			ELSE ''Published'' END
	FROM  Facstaff_Research_Publications FSRP  
	INNER JOIN Research_Publications RP 
		LEFT OUTER JOIN Research_Publication_Types RPT 
			ON RP.Research_Publication_Type = RPT.Research_Publication_Type 
		LEFT OUTER JOIN Research_Publication_Sub_Types RPST 
			ON RP.Research_Publication_Sub_Type = RPST.Research_Publication_Sub_Type  
		LEFT OUTER JOIN Scope_Codes SC  
			ON RP.Scope_ID = SC.Scope_ID  
		LEFT OUTER JOIN Publishers P  
			ON RP.Publisher_ID = P.Publisher_ID 
		LEFT OUTER JOIN Conferences C 
			ON RP.Conference_ID = C.Conference_ID  
		LEFT OUTER JOIN Journals J  
			ON RP.Journal_ID = J.Journal_ID  
		LEFT OUTER JOIN Book_Roles BR  
			ON RP.Book_Role_ID = BR.Book_Role_ID 
		LEFT OUTER JOIN Research_Publication_Contribution_Types RPCT  
			ON RP.Research_Publication_Contribution_Type = RPCT.Research_Publication_Contribution_Type  
		LEFT OUTER JOIN Publication_Issue_Codes PIC   
			ON RP.Publication_Issue_ID = PIC.Publication_Issue_ID  
		ON FSRP.Research_Publication_ID = RP.Research_Publication_ID 		
	WHERE   (RP.Accepted_Year >= ((SELECT DATEPART(YEAR, GETDATE())-2)) 
				OR RP.Published_Year >= ((SELECT DATEPART(YEAR, GETDATE())-2)) 
				OR RP.[Year >= ((SELECT DATEPART(YEAR, GETDATE())-2))) 
			AND FSRP.Active_Indicator <> 0 
			AND RP.Active_Indicator <> 0 
			AND FSRP.Facstaff_ID = ' +  CONVERT(VARCHAR, @Facstaff_ID ) + '
			AND RP.Research_Publication_Type ' + @Research_Publication_Type + '
	
	ORDER BY Publication_Status, RPYear DESC'
--	ORDER BY RP.Research_Publication_Status_Indicator, RPYear DESC '

EXEC(@SQLString)


SELECT TOP 5000 [Research_Publication_ID
      ,[Research_Publication_Type
      ,[Research_Publication_Title
      ,[Sub_Title
      ,[Research_Publication_Contribution_Type
      ,[Research_Publication_Sub_Type
      ,[Book_Role_ID
      ,[Scope_ID
      ,[Research_Publication_Refereed_Indicator
      ,[Journal_ID
      ,[Conference_ID
      ,[Research_Publication_Pages
      ,[Publication_Issue_ID
      ,[Publisher_ID
      ,[Year
      ,[Accepted_Year
      ,[Published_Year
      ,[Volume
      ,[Number
      ,[Research_Publication_Description
      ,[Research_Publication_Status_Indicator
      ,[Invited_Indicator
      ,[Conference_City
      ,[Conference_State
      ,[Conference_Country
      ,[Conference_Month
      ,[Full_Paper_Indicator
      ,[Editor
      ,[Revision_Indicator
      ,[Under_Review_Indicator
      ,[SSRN_ID
      ,[DOI
      ,[Perennial_Display_Indicator
      ,[Active_Indicator
      ,[Create_Datetime
      ,[Last_Update_Datetime
      ,[Last_Update_Network_ID
  FROM [Faculty_Staff_Holder.[dbo.[Research_Publications

*/
GO
