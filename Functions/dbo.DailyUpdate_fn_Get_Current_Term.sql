SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 10/18/2005
-- 12/19/08 STC - Updated to fix boundary condition (<= instead of =)
--		and select only term codes for UIUC (term_type_cd = S)
CREATE FUNCTION [dbo].[DailyUpdate_fn_Get_Current_Term]
(
	@todaysdate datetime
)
RETURNS varchar(6)  AS  
BEGIN 
	DECLARE @term_cd varchar(6)

	SELECT @term_cd = term_cd
	FROM Decision_Support.dbo.PUBLIC_EDW_T_TERM_CD
	WHERE @todaysdate <= term_end_dt
		AND term_type_cd = 'S'
	ORDER BY term_cd desc

	RETURN @term_cd
END


GO
