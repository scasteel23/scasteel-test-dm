SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/

-- NS 11/27/2017

CREATE PROC [dbo].[Adhoc_sp__Transition_05Initialize_Journal_Short_Names]
AS

	-- Extract all Journal_Name from dbo._DM_INTELLCONT and
	--	Insert new Journal_Name and Journal_Name_Short at dbo.FSDB_Journal_Web_IDs table accordingly
	-- Used effective at SP dbo.Shadow_INTELLCONT
	
	/*							
	SELECT [Journal_Name]
		  ,[Journal_Name_Short]  
		  ,[Create_Datetime]
	FROM [dbo].FSDB_Journal_Web_IDs

	SELECT JOURNAL_NAME, count(*)
	FROM _DM_INTELLCONT
	WHERE [Journal_Name] <> '' 
		AND [Journal_Name] is not null
		--AND [Journal_Name] NOT IN (SELECT JOURNAL_NAME FROM FSDB_Journal_Web_IDs)
	GROUP BY JOURNAL_NAME

	-- TRUNCATE TABLE [dbo].FSDB_Journal_Web_IDs
	*/


	INSERT INTO [dbo].FSDB_Journal_Web_IDs
	([Journal_Name]
		  ,[Journal_Name_Short]  
		  ,[Create_Datetime]
		  ,Active_Indicator)
	SELECT DISTINCT JOURNAL_NAME, '', getdate(),1
	FROM _DM_INTELLCONT
	WHERE [Journal_Name] <> '' 
		AND [Journal_Name] is not null
		AND [Journal_Name] NOT IN (SELECT JOURNAL_NAME FROM FSDB_Journal_Web_IDs)

	UPDATE dbo.FSDB_Journal_Web_IDs
	SET Journal_Name_Short = dbo.WP_fn_first_letters_in_string(Journal_Name)
	WHERE Journal_Name_Short IS NULL OR Journal_Name_Short=''
GO
