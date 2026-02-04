SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 10/16/2018
CREATE PROCEDURE [dbo].[shadow_Reference_Component_newly_added] 
AS 
BEGIN

	-- GET from journal_name and journal_id field from DM_Shadow_Staging.dbo._DM_INTELLCONT
	TRUNCATE TABLE dbo._DM_Reference_Component_newly_added

	INSERT INTO dbo._DM_Reference_Component_newly_added(journal_Name)
	SELECT DISTINCT journal_name --, journal_id
	FROM dbo._DM_INTELLCONT
	WHERE JOURNAL_NAME <> '' AND JOURNAL_NAME is not null	

	UPDATE dbo._DM_Reference_Component_newly_added
	SET download_Datetime = GETDATE()


	SELECT journal_name
      ,journal_id
      ,Download_Datetime
    FROM dbo._DM_Reference_Component_newly_added
END

GO
