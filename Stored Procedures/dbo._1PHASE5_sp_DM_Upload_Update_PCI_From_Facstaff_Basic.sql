SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/20/2018
-- See also Faculty_Staff_Holder.dbo.__DM_Excel_PCI
-- Before we run this SP, we must first download most current USERS from DM into _DM_USERS  (See shadow_USERS sp)
--	EXEC dbo.webservices_initiate @screen='USERS'
-- 	EXEC dbo.webservices_run_DTSX

CREATE  PROC [dbo].[_1PHASE5_sp_DM_Upload_Update_PCI_From_Facstaff_Basic]
AS

	/* Note that RANK is omitting mapping of Rank_ID in (23,24,25) since they are not defined in DM yet */
	/*
	<PCI id="125213026304" dmd:lastModified="2016-07-21T08:24:58">
			<PREFIX/>
			<FNAME>Nursalim</FNAME>
			<PFNAME>Nursalim</PFNAME>
			<MNAME/>
			<PMNAME/>
			<LNAME>Hadi</LNAME>
			<PLNAME/>
			<SUFFIX/>
			<ALT_NAME/>
			<ENDPOS/>
			<EMAIL>nhadi@illinois.edu</EMAIL>
			<EMERGENCY_CONTACT>nursalim.hadi@bus.illinois.edu</EMERGENCY_CONTACT>
			<WEBSITE>facebook.com/nursalim.hadi</WEBSITE>
			<TWITTER/>
			<LINKEDIN/>
					<GOOGLE_SCHOLAR_ID/>
			<ORCID/>
			<UPLOAD_CV/>
			<SHOW_CV>Yes</SHOW_CV>
			<UPLOAD_PHOTO/>
			<SHOW_PHOTO>Yes</SHOW_PHOTO>
			<SHOW_COLLEGE>Yes</SHOW_COLLEGE>
			<SHOW_DEPT>Yes</SHOW_DEPT>
			<SHOW_PROFILE>Yes</SHOW_PROFILE>
			<PROFILE_ID/>
			<STAFF_CLASS/>
			<RANK/>
			<DOC_STATUS/>
			<DOC_DEPT/>
			<DOC_TERM/>
			<BUS_PERSON>Yes</BUS_PERSON>
			<BUS_FACULTY>No</BUS_FACULTY>
			<ACTIVE>Yes</ACTIVE>
			<LINK id="125213026306">
				<NAME/>
				<URL/>
			</LINK>
		</PCI>

		<Data dmd:date="2018-04-02">
<Record userId="1940561" username="brownjr" termId="6117" dmd:surveyId="17825302">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Office of the Dean" text="Office of the Dean" />
<PCI id="130712037376" dmd:lastModified="2018-01-04T16:40:35">
<FNAME>Jeffrey</FNAME>
<MNAME>R.</MNAME>
<LNAME>Brown</LNAME>
<PFNAME />
<PMNAME />
<PLNAME />
<EMAIL>brownjr@illinois.edu</EMAIL>
<DTM_DOB>February</DTM_DOB>
<DTD_DOB>16</DTD_DOB>
<DTY_DOB>1968</DTY_DOB>
<DOB_START>1968-02-16</DOB_START>
<DOB_END>1968-02-16</DOB_END>
<GENDER>Female</GENDER>
<ETHNICITY />
<CITIZEN />
<GOOGLE_SCHOLAR_ID>PrxFp1MAAAAJ</GOOGLE_SCHOLAR_ID>
<ORCID />
<SSRN_ID>155077</SSRN_ID>
<UPLOAD_CV>brownjr/pci/Brown Full CV January 9 2016-1.pdf</UPLOAD_CV>
<SHOW_CV>Yes</SHOW_CV>
<UPLOAD_PHOTO>brownjr/pci/jeff_brown1_resize-1.jpg</UPLOAD_PHOTO>
<SHOW_PHOTO>Yes</SHOW_PHOTO>
<SHOW_COLLEGE>Yes</SHOW_COLLEGE>
<SHOW_DEPT>Yes</SHOW_DEPT>
<SHOW_PROFILE>Yes</SHOW_PROFILE>
<PROFILE_URL>https://business.illinois.edu/profile/Jeffrey-Brown</PROFILE_URL>
<RANK />
<STAFF_CLASS />
<DOC_STATUS />
<DOC_DEPT />
<DOC_TERM />
<BUS_PERSON>Yes</BUS_PERSON>
<BUS_FACULTY>Yes</BUS_FACULTY>
<ACTIVE>Yes</ACTIVE>
 </PCI>
 </Record>
</Data>

*/

   SET NOCOUNT ON


   SELECT DISTINCT FB.Network_ID as USERNAME
      ,FB.Facstaff_ID
	  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_EDW_PERS_ID(FB.Facstaff_ID) as EDW_PERS_ID
	  ,FB.Facstaff_ID as FACSTAFFID
	  ,FB.EDW_PERS_ID as EDWPERSID
	
	  ,FB.first_name as FNAME
	  ,ISNULL(FB.middle_name,'') as MNAME
	  ,FB.last_name as LNAME 

	  ,ISNULL(PERS_PREFERRED_FNAME,'') AS PFNAME
	  ,'' as PMNAME
	  ,ISNULL(Professional_Last_Name,'') as PLNAME 
	  ,Network_ID+'@illinois.edu' as EMAIL
	  ,CASE WHEN Birth_Date is NULL THEN ''
		ELSE DATENAME(month,Birth_Date) END  as DTM_DOB
	  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(DAY, Birth_Date)),'')  as DTD_DOB
	  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(YEAR, Birth_Date)),'') as DTY_DOB
	  ,CONVERT(varchar(12), Birth_Date,111) as DOB_START
	  ,CONVERT(varchar(12), Birth_Date,111) as DOB_END
	  ,CASE Gender when 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE '' END as GENDER
	  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Ethnicity(Ethnicity_ID) as ETHNICITY
	  ,Faculty_Staff_Holder.dbo.DM_fn_Lookup_Citizenship(Citizenship_ID) as  CITIZEN	 -- No need to submit this since we will have it at the BANNER screen
	  ,ISNULL(SSRN_ID,'') as  SSRN_ID 
	  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Google_Scholar_ID(GOOGLE_SCHOLAR_ID) as GOOGLE_SCHOLAR_ID
	  ,ISNULL(ORCID,'') as ORCID
	  --,ISNULL(FBO.Biographical_Sketch,'') as BIO_SKETCH
	  --,'' as PROF_INTERESTS
	  --,ISNULL(Teaching_Interests,'') as TEACHING_INTERESTS
	  --,ISNULL(Research_Interests,'') as RESEARCH_INTERESTS
      
  	  ,'' as UPLOAD_CV		-- no need to set
	  ,'Yes' as SHOW_CV

	  ,'' as  UPLOAD_PHOTO		-- no need to set
	  ,'Yes' as SHOW_PHOTO
	  ,'Yes' as SHOW_COLLEGE
	  ,'Yes' as SHOW_DEPT
	  ,CASE FB.Active_Indicator WHEN 1 THEN 'Yes' ELSE 'No' END as  SHOW_PROFILE
		
	  ,Faculty_Staff_Holder.dbo.WP_fn_Get_SomeID_from_FSID(FB.Facstaff_ID) as PROFILE_ID		
	  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Staff_Classification_Name(Staff_Classification_ID) as  STAFF_CLASS
	  ,Faculty_Staff_Holder.dbo.DM_fn_Lookup_Rank (Rank_ID) as [RANK]
	  , CASE FB.Doctoral_Flag 
			WHEN 0 THEN 'None' 
			WHEN 1 THEN 'Current PhD Student'
			WHEN 2 THEN 'Awarded PhD'
			WHEN 3 THEN 'Not Awarded PhD (Left Program)'
			WHEN 4 THEN 'Not Currently Registered'  -- temporary indicator should set to 1-3 daily
			ELSE 'None' 
		END as DOC_STATUS
			
	  , Faculty_Staff_Holder.dbo.__DM_fn_Get_Department(FB.Doctoral_Department_ID) as DOC_DEPT
	  , ISNULL(Faculty_Staff_Holder.dbo.__DM_fn_Get_Term_Name (FB.Doctoral_Award_Term_CD),'') as DOC_TERM
	  ,CASE Bus_Person_Indicator WHEN 1 Then 'Yes' ELSE 'No' END as BUS_PERSON
	  ,CASE Faculty_Staff_Indicator WHEN 1 Then 'Yes' ELSE 'No' END as BUS_FACULTY
	  ,CASE UDM.Enabled_Indicator WHEN 1 Then 'Yes' ELSE 'No' END as ACTIVE
	
   INTO #tempPCI

   FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FB
			INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DM
			ON FB.Facstaff_ID = DM.FacstaffID
			INNER JOIN DM_Shadow_Staging.dbo._UPLOAD_DM_USERS UDM
			ON FB.Facstaff_ID = UDM.FacstaffID
   WHERE  FB.first_name is not NULL
		AND FB.last_name is not NULL
		AND FB.EDW_PERS_ID is not NULL
		--AND FB.Facstaff_ID In (SELECT FacstaffID FROM DM_Shadow_Staging.dbo._DM_USERS WHERE FacstaffID <> 0)
		--AND BUS_Person_Indicator=1
	




   -- PRINT all fields
   --   Select Column_Name, DATA_TYPE, 
			--CASE WHEN CHARACTER_MAXIMUM_LENGTH is not NULL THEN '('+ cast(CHARACTER_MAXIMUM_LENGTH as varchar)+') NULL,'
			--ELSE ' NULL,' END
			--From tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tempPCI%'

  -- -- NS 3/17/2017: replace TAB, CRLF, source from Scott Casteel
	 --UPDATE #tempPCI
	 --SET TEACHING_INTERESTS = replace(replace(replace(replace(replace(replace(
  --                      replace(replace(replace(TEACHING_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
  --                      '     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		--,RESEARCH_INTERESTS = replace(replace(replace(replace(replace(replace(
  --                      replace(replace(replace(RESEARCH_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
  --                      '     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')
   TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
   INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_PCI(
		
		USERNAME
		,FacstaffID 
		,EDWPERSID
		,FNAME
		,MNAME
		,LNAME
		,PFNAME
		,PMNAME
		,PLNAME
		,EMAIL

		,DTM_DOB
		,DTD_DOB
		,DTY_DOB
		,GENDER
		,ETHNICITY
		,CITIZEN
		,SSRN_ID
		,GOOGLE_SCHOLAR_ID
		,ORCID
		----,BIO_SKETCH
		----,PROF_INTERESTS
		----,TEACHING_INTERESTS
		----,RESEARCH_INTERESTS
		--,UPLOAD_CV
		,SHOW_CV

		--,UPLOAD_PHOTO
		,SHOW_PHOTO
		,SHOW_COLLEGE
		,SHOW_DEPT
		,SHOW_PROFILE
		,PROFILE_URL
		,STAFF_CLASS
		,[RANK]
		,DOC_STATUS
		,DOC_DEPT
		,DOC_TERM
		,BUS_PERSON
		,BUS_FACULTY
		,ACTIVE
		,Update_Datetime)

   SELECT USERNAME
		,FacstaffID 
		,EDWPERSID
		,FNAME
		,MNAME
		,LNAME
		,PFNAME
		,PMNAME
		,PLNAME
		,EMAIL

		,DTM_DOB
		,DTD_DOB
		,DTY_DOB
		,GENDER
		,ETHNICITY
		,CITIZEN
		,SSRN_ID
		,GOOGLE_SCHOLAR_ID
		,ORCID
		----,BIO_SKETCH

		----,PROF_INTERESTS
		----,TEACHING_INTERESTS
		----,RESEARCH_INTERESTS
		--,'' as UPLOAD_CV
		,SHOW_CV

		--,'' as UPLOAD_PHOTO
		,SHOW_PHOTO
		,SHOW_COLLEGE
		,SHOW_DEPT
		,SHOW_PROFILE
		,CASE WHEN PROFILE_ID IS NULL THEN ''
			WHEN PROFILE_ID = '' THEN ''
			ELSE 'https://business.illinois.edu/profile/' + Profile_ID
			END as Profile_URL
		,STAFF_CLASS
		,[RANK]
		,DOC_STATUS
		,DOC_DEPT
		,DOC_TERM
		,BUS_PERSON
		,BUS_FACULTY
		,ACTIVE
		,getdate()

   FROM #tempPCI

   UPDATE newtable
   SET newtable.seq = newtable.newseq
   FROM (SELECT seq, USERNAME, ROW_NUMBER() OVER (ORDER BY USERNAME) newseq
		 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_PCI) newtable


   UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
   SET Record_Status = 'NEW'
   WHERE USERNAME NOT IN (SELECT USERNAME FROM DM_Shadow_Staging.dbo._DM_PCI)

   UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
   SET Record_Status = 'CUR'
   WHERE Record_Status IS NULL

  -- SELECT USERNAME   
		--,Facstaff_ID, EDW_PERS_ID
		--,FNAME
		--,MNAME
		--,LNAME
		--,PFNAME
		--,PMNAME
		--,PLNAME
		--,EMAIL

		--,DTM_DOB
		--,DTD_DOB
		--,DTY_DOB
		--,GENDER
		--,ETHNICITY
		--,'' as CITIZEN
		--,SSRN_ID
		--,GOOGLE_SCHOLAR_ID
		--,ORCID
		----,BIO_SKETCH

		----,PROF_INTERESTS
		----,TEACHING_INTERESTS
		----,RESEARCH_INTERESTS
		--,'' as UPLOAD_CV
		--,SHOW_CV

		--,'' as UPLOAD_PHOTO
		--,SHOW_PHOTO
		--,SHOW_COLLEGE
		--,SHOW_DEPT
		--,SHOW_PROFILE
		--,PROFILE_ID
		--,STAFF_CLASS
		--,[RANK]
		--,DOC_STATUS
		--,DOC_DEPT
		--,DOC_TERM
		--,BUS_PERSON
		--,BUS_FACULTY
		--,ACTIVE
	
  -- FROM #tempPCI

   /*	
		FNAME
		MNAME
		LNAME
		PFNAME
		PMNAME
		PLNAME
		EMAIL

		DTM_DOB
		DTD_DOB
		DTY_DOB
		GENDER
		ETHNICITY
		CITIZEN
		SSRN_ID
		GOOGLE_SCHOLAR_ID
		BIO_SKETCH

		PROF_INTERESTS
		TEACHING_INTERESTS
		RESEARCH_INTERESTS
		UPLOAD_CV
		SHOW_CV

		UPLOAD_PHOTO
		SHOW_PHOTO
		SHOW_COLLEGE
		SHOW_DEPT
		SHOW_PROFILE
		PROFILE_ID
		STAFF_CLASS
		DOC_STATUS
		DOC_DEPT
		DOC_TERM
		BUS_PERSON
		BUS_FACULTY
		ACTIVE

   */





GO
