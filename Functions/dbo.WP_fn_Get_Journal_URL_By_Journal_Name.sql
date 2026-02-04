SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 11/27/2017

CREATE  FUNCTION [dbo].[WP_fn_Get_Journal_URL_By_Journal_Name](@Journal_Name varchar(400))
	RETURNS VARCHAR(500)
	AS
BEGIN
	-- called by
	--		SP: dbo.WP_sp_Get_Publications_By_Facstaff_ID
	--		SP: dbo.WP_sp_Get_Publications_By_Facstaff_ID_AllPublications

	-- PRINT dbo.[WP_fn_Get_Journal_URL_By_Journal_Name] ('Journal of Financial Economics')
	DECLARE @JName AS VARCHAR(400) 
	DECLARE @JNameShort AS VARCHAR(400) 
	DECLARE @JournalString AS VARCHAR(500)
	DECLARE @WebsiteURL AS VARCHAR(100)

	SET @JournalString = ''
	SET @JNameShort = NULL
	--NS: 9/19/2014 Not needed since we are referring to relative address, i.e. w/o a server address
	--SET @WebsiteURL = dbo.Adhoc_fn_Get_Website_Prefix('College Faculty Profile')
						
	SELECT	@JName = Journal_Name, @JNameShort = Journal_Name_short
	FROM	dbo.FSDB_Journal_Web_IDs 
	WHERE	Journal_Name = @Journal_Name 
			AND Active_Indicator = 1

	IF @JNameShort IS NOT NULL OR Len(@JNameShort) <> 0 -- Start of @JID NOT NULL 
		BEGIN 		
			SET @JournalString =  '<A target=''_blank'' HREF=/profile/journals-' + @JNameShort + '>' +   @JName + '</A> ' 
		END 
	
	RETURN @JournalString
END

/*
 
DECLARE @JournalString VARCHAR(800)
SET @JournalString = Faculty_staff_Holder.dbo.WP_fn_Get_Journal_URL_By_RPID ('46')
PRINT @JournalString

			
			
*/

GO
