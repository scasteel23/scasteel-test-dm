SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[OUTLOOK_fn_Get_Facstaff_Telephone] (@facstaff_id int, @tele_type int)
RETURNS varchar(30)  AS  
BEGIN 
	DECLARE @area varchar(3)
	DECLARE @phone varchar(8)
	DECLARE @ext varchar(20)
	DECLARE @int varchar(20)
	DECLARE @completephone varchar(30)

	SET @completephone = ''

	SELECT @area = telephone_area_code, @phone = telephone_number, @ext = telephone_extension, @int=Telephone_International_Access
	FROM dbo.Factstaff_Telephones
	WHERE Facstaff_ID = @facstaff_id AND Telehone_Type_Code = @tele_type AND active_indicator = 1

	IF @int is not null and rtrim(@int) <> ''
		RETURN @int	    	

	IF @ext is not null and rtrim(@ext) <> ''
		SET @ext = ' Ext ' + @ext

	IF @area is not null and rtrim(@area) <> ''
	     BEGIN
	     	IF @phone is not null and rtrim(@phone) <> ''
		      SET @completephone = @area + ' - ' + @phone + ' ' + @ext
		-- do not show phone if they have only area code
	     END
	ELSE
	     BEGIN
	     	IF @phone is not null and rtrim(@phone) <> ''
		      SET @completephone = @phone + ' ' + @ext
	     END

	RETURN @completephone
	
		
END
GO
