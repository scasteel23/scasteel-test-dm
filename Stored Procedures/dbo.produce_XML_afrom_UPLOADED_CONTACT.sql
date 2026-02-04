SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 1/24/2018: it works
-- NS 1/23/2018 resumed
	-- 1) First step in Faculty_Staff_Holder.dbo.__DM_Excel_CONTACT SP:
	--		Get all courses from 
	--		Faculty_Staff_Holder.dbo.FACSTAFF_ADDRESSES and Faculty_Staff_Holder.dbo.FACSTAFF_BASIC
	--		into DM_Shadow_Staging.dbo._UPLOADED_DM_CONTACT table
	--		EXEC Faculty_Staff_Holder.dbo.__DM_Excel_CONTACT
	-- 2) Second step this SP: Generate XML from DM_Shadow_Staging.dbo._UPLOADED_DM_CONTACT table and insert into the queue dbo.webservices_requests table
	--		EXEC DM_Shadow_Staging.dbo.produce_XML_afrom_UPLOADED_CONTACT @submit = 1
	-- 3) Third step run the SSIX package 
	--		EXEC DM_Shadow_Staging.dbo.webservices_run_DTSX
CREATE PROC [dbo].[produce_XML_afrom_UPLOADED_CONTACT] ( @submit BIT=0 )
AS

/*
	UPLOAD sample:
	<Data>
	<Record username="nhadi">
    	<CONTACT>
 				<BUILDING>Wohlers Hall</BUILDING>
				<ROOM>460</ROOM>
				<OPHONE1>217</OPHONE1>
				<OPHONE2>333</OPHONE2>
				<OPHONE3>2227</OPHONE3>
                
				<MAILBOX />

				<ADDL_BUILDING>Digital Computer Laboratory</ADDL_BUILDING>
				<ADDL_ROOM>3310</ADDL_ROOM>
				<ADDL_PHONE1>217</ADDL_PHONE1>
				<ADDL_PHONE2>417</ADDL_PHONE2>
				<ADDL_PHONE3>4338</ADDL_PHONE3>

				<ADDRESS_DISPLAY>Official Campus Address</ADDRESS_DISPLAY>
				<PHONE_DISPLAY>Additional Campus Phone</PHONE_DISPLAY>
				<OFFICE_HOURS>Mondays, Thursdays 3:00 - 5:00 PM</OFFICE_HOURS>
				<APPT_ONLY>Yes</APPT_ONLY>

				<CAMPUS_EMAIL>nhadi@illinois.edu</CAMPUS_EMAIL>
				<ADDL_EMAIL>fxhadi@gmail.com</ADDL_EMAIL>
				<HOMEPAGE_WEB_ADDRESS>http://facebook.com/nursalim.hadi</HOMEPAGE_WEB_ADDRESS>

				<SOCIAL_MEDIA>
					<TYPE>Website</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>https://whateverblogitis.it/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA>
					<TYPE>LinkedIn</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>https://linkedin.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA>
					<TYPE>Facebook</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>http://facebook.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA>
					<TYPE>Other</TYPE>
					<TYPE_OTHER>Research Insight</TYPE_OTHER>
					<WEB_ADDRESS>http://researchinsight.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<OTHER_PHONE>
					<TYPE>Business</TYPE>
					<PHONE1>1</PHONE1>
					<PHONE2>217</PHONE2>
					<PHONE3>333</PHONE3>
					<PHONE4>2227</PHONE4>
					<SHOW>Yes</SHOW>
				</OTHER_PHONE>
				<OTHER_PHONE>
					<TYPE>Mobile</TYPE>
					<PHONE1>1</PHONE1>
					<PHONE2>217</PHONE2>
					<PHONE3>417</PHONE3>
					<PHONE4>4338</PHONE4>
					<SHOW>Yes</SHOW>
				</OTHER_PHONE>

				<NAME>Shinta Kartika Hadi</NAME>
				<RELATION>Spouse</RELATION>
				<EMERGENCY_PHONE1>1</EMERGENCY_PHONE1>
				<EMERGENCY_PHONE2>217</EMERGENCY_PHONE2>
				<EMERGENCY_PHONE3>417</EMERGENCY_PHONE3>
				<EMERGENCY_PHONE4>1881</EMERGENCY_PHONE4>
				<EMERGENCY_EMAIL>skhadi@gmail.com</EMERGENCY_EMAIL>
			</CONTACT>
		 </Record>
	</Data>

	DOWNLOADED sample:
	<Data dmd:date="2017-09-19">
		<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
			<CONTACT id="148311027712" dmd:originalSource="MANUAL" dmd:lastModified="2017-07-28T15:50:55">
				<BUILDING />
				<ROOM />
				<OPHONE1 />
				<OPHONE2 />
				<OPHONE3 />

				<MAILBOX />

				<ADDL_BUILDING>Wohlers Hall</ADDL_BUILDING>
				<ADDL_ROOM>460</ADDL_ROOM>
				<ADDL_PHONE1>217</ADDL_PHONE1>
				<ADDL_PHONE2>417</ADDL_PHONE2>
				<ADDL_PHONE3>4338</ADDL_PHONE3

				<ADDRESS_DISPLAY>Official Campus Address</ADDRESS_DISPLAY>
				<PHONE_DISPLAY>Additional Campus Phone</PHONE_DISPLAY>
				<OFFICE_HOURS>Mondays, Thursdays 3:00 - 5:00 PM</OFFICE_HOURS>
				<APPT_ONLY>Yes</APPT_ONLY>

				<CAMPUS_EMAIL />
				<ADDL_EMAIL>fxhadi@gmail.com</ADDL_EMAIL>
				<HOMEPAGE_WEB_ADDRESS>http://facebook.com/nursalim.hadi</HOMEPAGE_WEB_ADDRESS>

				<SOCIAL_MEDIA id="148311027713">
					<TYPE>Website</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>https://business.illinois.edu/nhadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA id="148311027716">
					<TYPE>LinkedIn</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>https://linkedin.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA id="148311027717">
					<TYPE>Facebook</TYPE>
					<TYPE_OTHER />
					<WEB_ADDRESS>http://facebook.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<SOCIAL_MEDIA id="148311027718">
					<TYPE>Other</TYPE>
					<TYPE_OTHER>Research Insight</TYPE_OTHER>
					<WEB_ADDRESS>http://researchinsight.com/nursalim.hadi</WEB_ADDRESS>
					<SHOW>Yes</SHOW>
				</SOCIAL_MEDIA>
				<OTHER_PHONE id="148311027714">
					<TYPE>Business</TYPE>
					<PHONE1>1</PHONE1>
					<PHONE2>217</PHONE2>
					<PHONE3>333</PHONE3>
					<PHONE4>2227</PHONE4>
					<SHOW>Yes</SHOW>
				</OTHER_PHONE>
				<OTHER_PHONE id="148311027719">
					<TYPE>Mobile</TYPE>
					<PHONE1>1</PHONE1>
					<PHONE2>217</PHONE2>
					<PHONE3>417</PHONE3>
					<PHONE4>4338</PHONE4>
					<SHOW>Yes</SHOW>
				</OTHER_PHONE>

				<NAME>Shinta Hadi</NAME>
				<RELATION>Spouse</RELATION>
				<EMERGENCY_PHONE1>1</EMERGENCY_PHONE1>
				<EMERGENCY_PHONE2>217</EMERGENCY_PHONE2>
				<EMERGENCY_PHONE3>417</EMERGENCY_PHONE3>
				<EMERGENCY_PHONE4>1881</EMERGENCY_PHONE4>
				<EMERGENCY_EMAIL>skhadi@illinois.edu</EMERGENCY_EMAIL>
			</CONTACT>
		 </Record>
	</Data>
*/


--IF EXISTS (
--	SELECT 1
--	FROM dbo.webservices_requests
--	WHERE url LIKE '%/User/%'
--	HAVING -- last shadowed < last refreshed
--	MAX(CASE WHEN method='GET' AND processed IS NOT NULL THEN initiated ELSE NULL END) < MAX(CASE WHEN method<>'GET' THEN created ELSE NULL END)
--) RAISERROR('This data has not been shadowed since the last refresh.',18,1);
--ELSE 

BEGIN


	SELECT  u.username
			-- OFFICIAL
			,BUILDING
			,ROOM
			,MAILBOX
			,CAMPUS_EMAIL
			,OPHONE1
			,OPHONE2
			,OPHONE3
			
			-- USER EDITABLE
			,ADDL_BUILDING
			,ADDL_ROOM			
			,APPT_ONLY
			,ADDL_EMAIL
			,ADDL_PHONE1
			,ADDL_PHONE2
			,ADDL_PHONE3
			,OFFICE_HOURS
			,HOMEPAGE_WEB_ADDRESS 

			-- DSA
			,phone1_PHONE1,phone1_PHONE2,phone1_PHONE3,phone1_TYPE,phone1_SHOW
			,phone2_PHONE1,phone2_PHONE2,phone2_PHONE3,phone2_TYPE,phone2_SHOW
			,phone3_PHONE1,phone3_PHONE2,phone3_PHONE3,phone3_TYPE,phone3_SHOW
		INTO #contacts
		FROM dbo._UPLOADED_DM_CONTACT con
				Inner JOIN dbo._DM_USERS u
				ON con.username=u.username
		WHERE BUILDING is not NULL
		AND BUILDING not in (
					'Illini Center, 4th Floor'
					,'Illini Center, 39th Floor'
					,'Survey Building'
					,'Z2 Building'
					,'School of Social Work'
					,'504 E Pennsylvania'
					,'505 East Daniel'
					,'807 South Wright'
					,'2001 South First Street')
		AND (
			ADDL_BUILDING is NULL
			OR ADDL_BUILDING not in (
					'Illini Center, 4th Floor'
					,'Illini Center, 39th Floor'
					,'Survey Building'
					,'Z2 Building'
					,'School of Social Work'
					,'504 E Pennsylvania'
					,'505 East Daniel'
					,'807 South Wright'
					,'2001 South First Street'))


SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
INTO #updates
FROM (
	-- Fill in their Personal Information
	 --SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+username+'/CONTACT' url,
	 -- No need to hit USERNAME interface but just directly to CONTACT interface
	  SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONTACT' url,
		CAST((
			--SELECT NETID "@username",(SELECT
			--	FirstName FNAME,
			--	LastName LNAME
			--	FOR XML PATH('PCI'),TYPE
			--)FOR XML PATH('Record'),ROOT('Data')

			SELECT username "@username"
			,(SELECT
					-- OFFICIAL
					 BUILDING 
					,ROOM 
					,MAILBOX 
					,CAMPUS_EMAIL
					
					
					,OPHONE1 
					,OPHONE2 
					,OPHONE3   
					-- DSA
					,(SELECT phone1_TYPE as [TYPE]
								,phone1_SHOW as [SHOW]
								,phone1_PHONE1 as PHONE1
								,phone1_PHONE1 as PHONE2
								,phone1_PHONE3 as PHONE3
						WHERE phone1_TYPE is not NULL
						FOR XML PATH ('OTHER_PHONE'), TYPE
					)
					,(SELECT phone2_TYPE as [TYPE]
								,phone2_SHOW as [SHOW]
								,phone2_PHONE1 as PHONE1
								,phone2_PHONE1 as PHONE2
								,phone2_PHONE3 as PHONE3
						WHERE phone2_TYPE is not NULL
						FOR XML PATH ('OTHER_PHONE'), TYPE
					)
					,(SELECT phone3_TYPE as [TYPE]
								,phone3_SHOW as [SHOW]
								,phone3_PHONE1 as PHONE1
								,phone3_PHONE1 as PHONE2
								,phone3_PHONE3 as PHONE3
						WHERE phone3_TYPE is not NULL
						FOR XML PATH ('OTHER_PHONE'), TYPE
					)
					-- USER EDITABLE
					,ADDL_BUILDING
					,ADDL_ROOM			
					,APPT_ONLY
					,ADDL_EMAIL
					,ADDL_PHONE1
					,ADDL_PHONE2
					,ADDL_PHONE3
					,OFFICE_HOURS
					,HOMEPAGE_WEB_ADDRESS 
				  FOR XML PATH('CONTACT')
			 ,TYPE
			 )FOR XML PATH('Record'),ROOT('Data')

		)AS VARCHAR(MAX)) xml
	FROM #contacts
)x
ORDER BY username,o



IF @submit=1 BEGIN
	
	CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.username=u1.username ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r
	
	DROP TABLE #requests
END
ELSE SELECT * FROM #updates

DROP TABLE #updates

-- EXEC dbo.produce_XML_afrom_UPLOADED_CONTACT @submit = 0
-- EXEC dbo.produce_XML_afrom_UPLOADED_CONTACT @submit = 1
END
GO
