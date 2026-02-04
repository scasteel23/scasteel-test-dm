SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS  12/5/2018 : Rewritten for DM, no changes
-- NS  3/17/2015: added CrsSubj parameter
-- STC 7/5/07: created
-- derived from Adhoc_sp_Create_Initial_Course_Area_Mappings
-- applies the following mapping system to get area for a BADM course:
--
-- General & Business Law			X 0 X
-- Organizational Behavior			X 1 X
-- Marketing					X 2 X
-- Supply Chain Management			X 3 X
-- Strategy					X 4 X
-- Information Systems				X 5 X
-- Technology Management & New Products	X 6 X
-- Process Management & Management Science	X 7 X
-- International Business				X 8 X
-- Seminars & Independent Study			X 9 X
--
-- Also re-maps specific courses that don't fit the mapping scheme above:
-- 	BADM 365, BADM 366 --> Marketing
--           BADM 367, BADM 461 --> Strategy
--	BADM 460 --> Process Mgmt

CREATE  FUNCTION [dbo].[WP_fn_Get_Area_Name_For_New_Course]
(
	@CrsSubj VARCHAR(6),
	@CrsNbr VARCHAR(5)
)
RETURNS varchar(100) AS  
BEGIN 

	DECLARE @CourseAreaID AS INT
	DECLARE @CourseAreaName AS VARCHAR(50)

	SET @CourseAreaName = 'ALL'
	IF UPPER(@CrsSubj) = 'BADM'
		BEGIN
			-- Get default mapping area
			IF @CrsNbr LIKE '_0_' 
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 0, 2)
			ELSE IF @CrsNbr LIKE '_1_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 1, 2)
			ELSE IF @CrsNbr LIKE '_2_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 2, 2)
			ELSE IF @CrsNbr LIKE '_3_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 3, 2)
			ELSE IF @CrsNbr LIKE '_4_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 4, 2)
			ELSE IF @CrsNbr LIKE '_5_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 5, 2)
			ELSE IF @CrsNbr LIKE '_6_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 6, 2)
			ELSE IF @CrsNbr LIKE '_7_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 7, 2)
			ELSE IF @CrsNbr LIKE '_8_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 8, 2)
			ELSE IF @CrsNbr LIKE '_9_'
				SET @CourseAreaName = dbo.WP_fn_Get_Course_Group_Name_By_Course_Group_Identity(@CrsSubj, 9, 2)

			--IF @CrsNbr LIKE '_0_' 
			--	SET @CourseAreaName = 'General & Business Law'
			--ELSE IF @CrsNbr LIKE '_1_'
			--	SET @CourseAreaName = 'Organizational Behavior'
			--ELSE IF @CrsNbr LIKE '_2_'
			--	SET @CourseAreaName = 'Marketing'
			--ELSE IF @CrsNbr LIKE '_3_'
			--	SET @CourseAreaName = 'Supply Chain Management'
			--ELSE IF @CrsNbr LIKE '_4_'
			--	SET @CourseAreaName = 'Strategy'
			--ELSE IF @CrsNbr LIKE '_5_'
			--	SET @CourseAreaName = 'Information Systems'
			--ELSE IF @CrsNbr LIKE '_6_'
			--	SET @CourseAreaName = 'Technology Management & New Products'
			--ELSE IF @CrsNbr LIKE '_7_'
			--	SET @CourseAreaName = 'Process Management & Management Science'
			--ELSE IF @CrsNbr LIKE '_8_'
			--	SET @CourseAreaName = 'International Business'
			--ELSE IF @CrsNbr LIKE '_9_'
			--	SET @CourseAreaName = 'Seminars & Independent Study'

			-- Get alternate area for certain courses
			IF @CrsNbr = '365' OR @CrsNbr = '366'
				SET @CourseAreaName = 'Marketing'
			ELSE IF @CrsNbr = '367' OR @CrsNbr = '461'
				SET @CourseAreaName = 'Strategy'
			ELSE IF @CrsNbr = '460'
				SET @CourseAreaName = 'Process Management & Management Science'

			--SELECT @CourseAreaID = Course_Area_ID
			--FROM	dbo.Course_Area_Codes
			--WHERE Course_Area_Name = @CourseAreaName
		END
	-- SELECT dbo.WP_fn_Get_Area_Name_For_New_Course ('BADM', '390')
	RETURN @CourseAreaName
END





GO
