SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 11/30/2016
CREATE FUNCTION [dbo].[Get_Staff_Classification] 
	(
		@EMPEE_GROUP_CD as varchar(2)
	)
RETURNS VARCHAR(60)

BEGIN
	DECLARE @SC as VARCHAR(60)
	/*
	Staff_Classification_ID	
	1	Civil Service - Extra Help
	2	Academic Professional
	3	Civil Service - Department
	5	Graduate Assistant/Pre Doc Fellows
	6	Doctoral Student
	7	Academic Hourly & Grad Hourly
	8	Retiree/Annuitant
	9	Undergraduate Hourly
	11	Doctoral Student and Graduate Assistant/Pre Doc Fellows
	12	Unpaid
	13	Visiting Scholar
	14	Post Doc Fellows, Res Assoc, Interns

	EMPEE_GROUP_CD
	Group A (faculty & other academics)
	Group B (Academic Professionals)
	Group C (Civil Service Dept)
	Group E (Civil Service Extra Help)
	Group G (Graduate Assistants)
	Group H (Academic Hourly & Grad Hourly)
	Group P (Postdoc Fellows, Research Associates & Interns)
	Group S (Undergraduate Hourly)
	Group T (Retiree/Annuitant)
	Group U (Unpaid, Ignore don't put into FSDB)
	
	*/
	-- We combine PhD students and Employee classification into 1 field
	--		"Doctoral Student" cannot be looked up using this function
	-- We cannot combine Faculty into this fields since "Faculty" is the term we use to
	--		indicate whether the employee is considered a member in "Faculty" directory.
	--		An Academic Professional could be also a "Faculty".

	SET @SC = CASE 				
				WHEN @EMPEE_GROUP_CD='B' THEN 'Academic Professional'
				WHEN @EMPEE_GROUP_CD='C' THEN 'Civil Service - Department'
				WHEN @EMPEE_GROUP_CD='E' THEN 'Civil Service - Extra Help'
				WHEN @EMPEE_GROUP_CD='G' THEN 'Graduate Assistant/Pre Doc Fellows'
				WHEN @EMPEE_GROUP_CD='H' THEN 'Academic Hourly & Grad Hourly'
				WHEN @EMPEE_GROUP_CD='P' THEN 'Post Doc Fellows, Res Assoc, Interns'
				WHEN @EMPEE_GROUP_CD='S' THEN 'Undergraduate Hourly'
				WHEN @EMPEE_GROUP_CD='T' THEN 'Retiree/Annuitant'
				WHEN @EMPEE_GROUP_CD='U' THEN 'Unpaid'
				ELSE ''
			END

	RETURN @SC

END

GO
