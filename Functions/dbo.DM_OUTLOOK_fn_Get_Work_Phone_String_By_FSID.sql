SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE    FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Work_Phone_String_By_FSID](@FSID INT)
	RETURNS VARCHAR(30)
	AS
BEGIN
	

		DECLARE @WorkPhone VARCHAR(30)
		DECLARE @WorkPhoneAreaCode VARCHAR(20)
		DECLARE @WorkPhone1Code VARCHAR(20), @WorkPhone2Code varchar(20)
		
		SET @WorkPhone = '' 
		SET @WorkPhoneAreaCode = '' 
		SET @WorkPhone1Code = '' 
		SET @WorkPhone2Code = '' 
		
		SELECT DISTINCT @WorkPhoneAreaCode = ISNULL(OPHONE1,''), @WorkPhone1Code = isnull(OPHONE2,''),  @WorkPhone2Code=ISNULL(OPHONE3,'')
		FROM  dbo._DM_CONTACT  		
		WHERE   FacstaffID = @FSID 
				AND (Phone_Display = 'YES' OR Phone_Display = '')

		IF @WorkPhoneAreaCode <> ''
			SET @WorkPhoneAreaCode = '('+@WorkPhoneAreaCode + ') '
		IF @WorkPhone1Code <> '' and @WorkPhone2Code <> ''
			SET @WorkPhone = @WorkPhoneAreaCode + @WorkPhone1Code + '-' + @WorkPhone2Code
		
		RETURN(@WorkPhone)
	END






















GO
