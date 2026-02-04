SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- NS 9/26/2005

-- STC updated 1/12/11
-- NS  add bdate,gender, citzn 4/14/2011
-- STC 11/14/16 - Get NetID from T_NET_ID instead of V_EMPEE_CAMPUS_EMAIL_ADDR 
--					Select email based on EMAIL_PREFERRED_IND instead of EMAIL_STATUS_IND
-- STC 2/6/17 - Only add if EDW_PERS_ID not already present in Facstaff_Basic
-- STC 11/1/18 - Only add primary job to avoid duplicate entries (assuming not KM)
-- STC 4/17/20 - Updated to allow addition of employees with no job data
--				(Restructure joins, replace INNER with LEFT for job tables)
-- STC 4/17/20 - Add to both DM and FSDB
CREATE Procedure [dbo].[Adhoc_sp_Add_FSDB_Facstaff_Basic_From_EDW]
as

DECLARE @addEDW_PERS_ID INT
DECLARE @Department_ID INT
DECLARE @Faculty_Staff_Indicator BIT

-- SET @addEDW_PERS_ID = 3272160
-- SET @addEDW_PERS_ID = 2572590
-- SET @addEDW_PERS_ID = 2532038	-- Emily Krickl Ziegler
--SET @addEDW_PERS_ID = 3654472		-- Mei-Po Kwan 10/20/15
--SET @addEDW_PERS_ID = 2050930		-- Joseph Yun 11/14/16
--SET @addEDW_PERS_ID = 4242297		-- Mary Lee Gilliland 2/6/17
--SET @addEDW_PERS_ID = 4540144		-- Simrun Sethi 4/30/18
--SET @addEDW_PERS_ID = 3808291		-- Cristal Cardenas 6/1/18
--SET @addEDW_PERS_ID = 72326		-- Deborah Thurston 10/31/18
--SET @addEDW_PERS_ID = 1863663		-- David Weightman 11/8/18
--SET @addEDW_PERS_ID = 3437813		-- Evan Cropek 3/16/20
--SET @addEDW_PERS_ID = 31134		-- Marsha Hatchel 3/16/20
--SET @addEDW_PERS_ID = 3269524		-- Matias Kind 4/17/20
--SET @addEDW_PERS_ID = 4966457		-- Dominic Pickert 4/17/20
--SET @addEDW_PERS_ID = 4457929		-- Shinjae Won 12/21/21
SET @addEDW_PERS_ID = 4538490		-- Sureth Sethi 12/21/21

SET @Faculty_Staff_Indicator = 1
SET @Department_ID = 1

-- Departments: 1 BADM, 2 Finance, 3 ACCY, 4 Alumni, 6 BCS, 7 Advancement, 11 IT, 14 Dean, 15 IBC, 16 Ugrad, 19 T&M, 
--				21 Gies Affiliates, 28 Elearning, 30 Grad, 32 Magelli, 33 Online, 37 Gies

-- Add to DM_Shadow_Staging

INSERT INTO FSDB_Facstaff_Basic
(
	UIN, 
	Network_ID,
	Email_address,
	EDW_PERS_ID, 
	EMPEE_DEPT_CD, 
	EMPEE_DEPT_NAME, 
	EMPEE_GROUP_CD, 
	EMPEE_GROUP_DESC, 
	EMPEE_CLS_CD,
	EMPEE_CLS_LONG_DESC,
	First_Name,
	Last_Name, 
	Appointment_Percent, 
	Department_ID, 
	Faculty_Staff_Indicator, 
	Bus_Person_Manual_Entry_Indicator,
	Active_Indicator,
	BUS_Person_Indicator,
	College_List_Indicator, 
	Department_List_Indicator,
	College_Directory_Indicator
)

SELECT DISTINCT 
	eph.UIN, 
	--CASE WHEN  A.EMAIL_ADDR LIKE '%@ILLINOIS.EDU' THEN (LEFT(A.EMAIL_ADDR, (LEN(A.EMAIL_ADDR) - 13)))
	--	 ELSE (LEFT(A.EMAIL_ADDR, (LEN(A.EMAIL_ADDR) - 9)))
	--END,
	N.NETID_PRINCIPAL,
	A.EMAIL_ADDR,
	EPH.EDW_PERS_ID,	
	EJDH.JOB_DETL_DEPT_CD,  	
	EJDH.JOB_DETL_DEPT_NAME,  	
	EH.EMPEE_GROUP_CD, 
	EH.EMPEE_GROUP_DESC, 
	EH.EMPEE_CLS_CD, 
	EH.EMPEE_CLS_LONG_DESC, 
	EPH.PERS_FNAME, 	
	EPH.PERS_LNAME, 
	(EJDH.JOB_DETL_FTE * 100), 
	@Department_ID,
	@Faculty_Staff_Indicator,
	1,	-- Bus_Person_Manual_Entry_Indicator
	1,	-- Active_Indicator
	1,	-- BUS_Person_Indicator
	0,	-- College_List_Indicator
	0,	-- Department_List_Indicator
	1	-- College_Directory_Indicator

	FROM DECISION_SUPPORT_HR.dbo.EDW_V_EMPEE_PERS_HIST_1 EPH 	
	INNER JOIN DECISION_SUPPORT_HR.dbo.EDW_V_EMPEE_HIST_1 EH 	
		ON EPH.EDW_PERS_ID = EH.EDW_PERS_ID 
	LEFT OUTER JOIN DECISION_SUPPORT_HR.dbo.EDW_T_JOB_HIST JH
		ON EPH.EDW_PERS_ID = JH.EDW_PERS_ID 	
			AND JH.PRIMARY_JOB_IND = 'Y'
	LEFT OUTER JOIN DECISION_SUPPORT_HR.dbo.EDW_V_JOB_DETL_HIST_1 EJDH 	
		ON EJDH.EDW_PERS_ID = EPH.EDW_PERS_ID 
			AND EJDH.JOB_SUFFIX = JH.JOB_SUFFIX
			AND EJDH.POSN_NBR = JH.POSN_NBR
			AND EJDH.JOB_DETL_CUR_INFO_IND = 'Y'
			AND EJDH.JOB_DETL_STATUS_DESC = 'Active' 
			AND	EJDH.JOB_DETL_DATA_STATUS_DESC = 'Current'
	INNER JOIN DECISION_SUPPORT_HR.dbo.EDW_V_EMPEE_CAMPUS_EMAIL_ADDR A 	
		ON EPH.EDW_PERS_ID = A.EDW_PERS_ID 
			AND A.EMAIL_PREFERRED_IND = 'Y'
	INNER JOIN DECISION_SUPPORT_HR.dbo.EDW_T_NETID N
		ON EPH.EDW_PERS_ID = N.EDW_PERS_ID 
			AND N.EMPEE_HOME_CAMPUS_IND = 'Y'
	WHERE 
		-- Moved all of this to joins above to allow addition of employees with no job data yet
--		EJDH.JOB_DETL_CUR_INFO_IND = 'Y' AND 	
--		EJDH.JOB_DETL_STATUS_DESC = 'Active' AND
--		EJDH.JOB_DETL_DATA_STATUS_DESC = 'Current' AND 
		-- If not KM, only add Primary job to avoid duplicates
--		JH.PRIMARY_JOB_IND = 'Y' AND
--		JH.JOB_CUR_INFO_IND = 'Y' AND

		--EH.EMPEE_COLL_CD = 'KM' AND 
		--EJDH.JOB_DETL_COLL_CD = 'KM' AND 
		--EJDH.JOB_DETL_DEPT_CD = EH.EMPEE_DEPT_CD AND
		EPH.PERS_CUR_INFO_IND = 'Y' AND 
		EH.ACTIVE_EMPEE_IND = 'Y' AND 
		EH.EMPEE_CUR_INFO_IND = 'Y' AND
		--EJDH.EDW_PERS_ID IN ('3272160')
		EPH.EDW_PERS_ID = @addEDW_PERS_ID AND
		@addEDW_PERS_ID NOT IN (
			SELECT EDW_PERS_ID FROM FSDB_Facstaff_Basic WHERE EDW_PERS_ID IS NOT NULL
		)
		
		--EH.EMPEE_GROUP_CD <> 'S' AND	
		--EH.EMPEE_GROUP_CD <> 'H' AND 
		--EH.EMPEE_GROUP_CD <> 'U' AND 
		--EH.EMPEE_GROUP_CD <> 'G' AND 
		--((EH.EMPEE_GROUP_CD IN ('A', 'T') AND 	
		--		EJDH.JOB_DETL_FTE <> 0) OR
		--	(EH.EMPEE_GROUP_CD = 'B' AND 
		--		EJDH.JOB_DETL_FTE = 0))	AND	
		--(EJDH.JOB_DETL_DEPT_NAME = 'Accountancy' OR 		
		--	EH.EMPEE_DEPT_NAME = 'Accountancy') AND  		

  DECLARE @birthdate datetime
  DECLARE @gender varchar(1)
  DECLARE @citizenship varchar(2)
  select @birthdate =  BIRTH_DT, @gender = sex_cd, @citizenship = PERS_CITZN_TYPE_CD
  from DECISION_SUPPORT_HR.dbo.EDW_V_EMPEE_PERS_HIST_3
  where EDW_PERS_ID = @addEDW_PERS_ID
  order by PERS_HIST_EFF_DT asc
  
  UPDATE FSDB_Facstaff_Basic
  SET Citizenship_ID=@citizenship, Gender=@gender, Birth_Date=@birthdate
  WHERE EDW_PERS_ID = @addEDW_PERS_ID


INSERT INTO Faculty_Staff_Holder.dbo.Facstaff_Basic
(
	UIN, 
	Network_ID,
	Email_address,
	EDW_PERS_ID, 
	EMPEE_DEPT_CD, 
	EMPEE_DEPT_NAME, 
	EMPEE_GROUP_CD, 
	EMPEE_GROUP_DESC, 
	EMPEE_CLS_CD,
	EMPEE_CLS_LONG_DESC,
	First_Name,
	Last_Name, 
	Appointment_Percent, 
	Department_ID, 
	Faculty_Staff_Indicator, 
	Bus_Person_Manual_Entry_Indicator,
	Active_Indicator,
	BUS_Person_Indicator,
	College_List_Indicator, 
	Department_List_Indicator,
	College_Directory_Indicator,
	Citizenship_ID,
	Gender,
	Birth_Date
)

SELECT 
	UIN, 
	Network_ID,
	Email_address,
	EDW_PERS_ID, 
	EMPEE_DEPT_CD, 
	EMPEE_DEPT_NAME, 
	EMPEE_GROUP_CD, 
	EMPEE_GROUP_DESC, 
	EMPEE_CLS_CD,
	EMPEE_CLS_LONG_DESC,
	First_Name,
	Last_Name, 
	Appointment_Percent, 
	Department_ID, 
	Faculty_Staff_Indicator, 
	Bus_Person_Manual_Entry_Indicator,
	Active_Indicator,
	BUS_Person_Indicator,
	College_List_Indicator, 
	Department_List_Indicator,
	College_Directory_Indicator,
	Citizenship_ID,
	Gender,
	Birth_Date

	FROM FSDB_Facstaff_Basic
	WHERE EDW_PERS_ID = @addEDW_PERS_ID AND
		@addEDW_PERS_ID NOT IN (
			SELECT EDW_PERS_ID FROM Faculty_Staff_Holder.dbo.Facstaff_Basic WHERE EDW_PERS_ID IS NOT NULL
		)
GO
