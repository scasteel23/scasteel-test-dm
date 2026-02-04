SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 10/12/2017: use shadow_screen_data2()
-- NS 9/20/2017: start working
-- NS 7/27/2017: Get the final screen/SchemaEntity definition, not tested
-- NS 6/29/2017: 

/*
	Manual run to shadow individual CONTACT screen
	EXEC dbo.webservices_initiate @screen='CONTACT'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_CONTACT] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all CONTACT data from
	-- https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONTACT
	-- Parse the incoming XML
	/*
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



	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,

		ISNULL(Item.value('(BUILDING/text())[1]','varchar(100)'),'')BUILDING,
		ISNULL(Item.value('(ROOM/text())[1]','varchar(100)'),'')ROOM,
		ISNULL(Item.value('(OPHONE1/text())[1]','varchar(10)'),'')OPHONE1,
		ISNULL(Item.value('(OPHONE2/text())[1]','varchar(10)'),'')OPHONE2,
		ISNULL(Item.value('(OPHONE3/text())[1]','varchar(10)'),'')OPHONE3,
		ISNULL(Item.value('(MAILBOX/text())[1]','varchar(100)'),'')MAILBOX,

		ISNULL(Item.value('(ADDL_BUILDING/text())[1]','varchar(100)'),'')ADDL_BUILDING,
		ISNULL(Item.value('(ADDL_ROOM/text())[1]','varchar(100)'),'')ADDL_ROOM,
		ISNULL(Item.value('(ADDL_PHONE1/text())[1]','varchar(10)'),'')ADDL_PHONE1,
		ISNULL(Item.value('(ADDL_PHONE2/text())[1]','varchar(10)'),'')ADDL_PHONE2,
		ISNULL(Item.value('(ADDL_PHONE3/text())[1]','varchar(10)'),'')ADDL_PHONE3,
		
		ISNULL(Item.value('(ADDRESS_DISPLAY/text())[1]','varchar(50)'),'')ADDRESS_DISPLAY,
		ISNULL(Item.value('(PHONE_DISPLAY/text())[1]','varchar(50)'),'')PHONE_DISPLAY,

		ISNULL(Item.value('(OFFICE_HOURS/text())[1]','varchar(100)'),'')OFFICE_HOURS,

		ISNULL(Item.value('(APPT_ONLY/text())[1]','varchar(3)'),'')APPT_ONLY,
		ISNULL(Item.value('(CAMPUS_EMAIL/text())[1]','varchar(100)'),'')CAMPUS_EMAIL,
		ISNULL(Item.value('(ADDL_EMAIL/text())[1]','varchar(100)'),'')ADDL_EMAIL,
		ISNULL(Item.value('(HOMEPAGE_WEB_ADDRESS/text())[1]','varchar(200)'),'')HOMEPAGE_WEB_ADDRESS,

		ISNULL(Item.value('(NAME/text())[1]','varchar(100)'),'')NAME,
		ISNULL(Item.value('(RELATION/text())[1]','varchar(100)'),'')RELATION,
		ISNULL(Item.value('(EMERGENCY_PHONE1/text())[1]','varchar(10)'),'')EMERGENCY_PHONE1,
		ISNULL(Item.value('(EMERGENCY_PHONE2/text())[1]','varchar(10)'),'')EMERGENCY_PHONE2,
		ISNULL(Item.value('(EMERGENCY_PHONE3/text())[1]','varchar(10)'),'')EMERGENCY_PHONE3,
		ISNULL(Item.value('(EMERGENCY_PHONE4/text())[1]','varchar(10)'),'')EMERGENCY_PHONE4,
		ISNULL(Item.value('(EMERGENCY_EMAIL/text())[1]','varchar(100)'),'')EMERGENCY_EMAIL,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime			
	INTO #_DM_CONTACT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./CONTACT')Items(Item);
	
	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	--SELECT CONTACT.value('@id','bigint')id,
	--	CONTACT.value('@userid','bigint')userid,
	--	CONTACT.value('@dmd:lastModified','date')lastModified,
	--	CONTACT.value('@username','varchar(60)')USERNAME,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('TYPE[1]','varchar(100)'),'')[TYPE],
	--	ISNULL(Item.value('TYPE_OTHER[1]','varchar(100)'),'')TYPE_OTHER,
	--	ISNULL(Item.value('WEB_ADDRESS[1]','varchar(100)'),'')WEB_ADDRESS,
	--	ISNULL(Item.value('SHOW[1]','varchar(3)'),'')SHOW,
	--	ROW_NUMBER()OVER(PARTITION BY CONTACT ORDER BY Item)sequence	
	--INTO #_DM_CONTACT_SOCIAL_MEDIA
	--FROM @xml.nodes('/Data/Record/CONTACT')CONTACTs(CONTACT)
	--	CROSS APPLY CONTACTs.CONTACT.nodes('./SOCIAL_MEDIA')Items(Item);

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT CONTACT.value('@id','bigint')id,
		REC.value('@userId','bigint')userid,
		CONTACT.value('@dmd:lastModified','date')lastModified,
		REC.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('TYPE[1]','varchar(100)'),'')[TYPE],
		ISNULL(Item.value('TYPE_OTHER[1]','varchar(100)'),'')TYPE_OTHER,
		ISNULL(Item.value('WEB_ADDRESS[1]','varchar(100)'),'')WEB_ADDRESS,
		ISNULL(Item.value('SHOW[1]','varchar(3)'),'')SHOW,
		ROW_NUMBER() OVER(PARTITION BY CONTACT ORDER BY Item)sequence,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_CONTACT_SOCIAL_MEDIA
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./CONTACT')CONTACTs(CONTACT)
		CROSS APPLY CONTACTs.CONTACT.nodes('./SOCIAL_MEDIA')Items(Item);

	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	--SELECT CONTACT.value('@id','bigint')id,
	--	CONTACT.value('@userid','bigint')userid,
	--	CONTACT.value('@dmd:lastModified','date')lastModified,
	--	CONTACT.value('@username','varchar(60)')USERNAME,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('TYPE[1]','varchar(100)'),'')[TYPE],
	--	ISNULL(Item.value('PHONE1[1]','varchar(10)'),'')PHONE1,
	--	ISNULL(Item.value('PHONE2[1]','varchar(10)'),'')PHONE2,
	--	ISNULL(Item.value('PHONE3[1]','varchar(10)'),'')PHONE3,
	--	ISNULL(Item.value('PHONE4[1]','varchar(10)'),'')PHONE4,
	--	ISNULL(Item.value('SHOW[1]','varchar(3)'),'')SHOW,
	--	ROW_NUMBER()OVER(PARTITION BY CONTACT ORDER BY Item)sequence	
	--INTO #_DM_CONTACT_OTHER_PHONE
	--FROM @xml.nodes('/Data/Record/CONTACT')CONTACTs(CONTACT)
	--	CROSS APPLY CONTACTs.CONTACT.nodes('./OTHER_PHONE')Items(Item);

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT CONTACT.value('@id','bigint')id,
		REC.value('@userId','bigint')userid,
		CONTACT.value('@dmd:lastModified','date')lastModified,
		REC.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('TYPE[1]','varchar(100)'),'')[TYPE],
		ISNULL(Item.value('PHONE1[1]','varchar(10)'),'')PHONE1,
		ISNULL(Item.value('PHONE2[1]','varchar(10)'),'')PHONE2,
		ISNULL(Item.value('PHONE3[1]','varchar(10)'),'')PHONE3,
		ISNULL(Item.value('PHONE4[1]','varchar(10)'),'')PHONE4,
		ISNULL(Item.value('SHOW[1]','varchar(3)'),'')SHOW,
		ROW_NUMBER()OVER(PARTITION BY CONTACT ORDER BY Item)sequence,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_CONTACT_OTHER_PHONE
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./CONTACT')CONTACTs(CONTACT)
		CROSS APPLY CONTACTs.CONTACT.nodes('./OTHER_PHONE')Items(Item);

	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8
	SET @tolerance = 0.8

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_CONTACT) < 1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='CONTACT has no data' WHERE [ID]=@webservices_requests_id	
			RAISERROR('CONTACT has no Data',18,1)
		END
	ELSE 
		-- Delete & Insert the staging data
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-CONTACT','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-CONTACT Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-CONTACT Import Locked' WHERE [ID]=@webservices_requests_id			
				END
		ELSE BEGIN
			
			IF @userid is not null
				BEGIN
					-- Update records of @userid at Main tables _DM_CONTACT in DM_Shadow_Staging and DM_Shadow_Production databases
					SET @fields = 'id,userid,username,lastModified,Create_Datetime,Download_Datetime,termID,surveyID' +
									',BUILDING,ROOM,OPHONE1,OPHONE2,OPHONE3,MAILBOX' +
									',ADDL_BUILDING,ADDL_ROOM,ADDL_PHONE1,ADDL_PHONE2,ADDL_PHONE3' +
									',ADDRESS_DISPLAY,PHONE_DISPLAY,OFFICE_HOURS,APPT_ONLY,CAMPUS_EMAIL,ADDL_EMAIL,HOMEPAGE_WEB_ADDRESS' +
									',NAME,RELATION,EMERGENCY_PHONE1,EMERGENCY_PHONE2,EMERGENCY_PHONE3,EMERGENCY_PHONE4,EMERGENCY_EMAIL' 
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
					    ,@table='_DM_CONTACT'
						,@cols=@fields
						,@userid=@userid				

					-- Update records of @userid at relational tables _DM_CONTACT_OTHER_PHONE in DM_Shadow_Staging and DM_Shadow_Production databases		    					
					SET @fields = 'id,itemid,USERNAME, lastModified, Create_Datetime,Download_Datetime'+
											',TYPE,PHONE1,PHONE2,PHONE3,PHONE4,SHOW	'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
						,@table='_DM_CONTACT_OTHER_PHONE'
						,@cols=@fields
						,@userid=@userid

					-- Update records of @userid at relational tables _DM_CONTACT_SOCIAL_MEDIA in DM_Shadow_Staging and DM_Shadow_Production databases		    					
					SET @fields = 'id,itemid,USERNAME,lastModified,Create_Datetime,Download_Datetime' + 
									',TYPE,TYPE_OTHER,WEB_ADDRESS,SHOW'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
						,@table='_DM_CONTACT_SOCIAL_MEDIA'
						,@cols=@fields
						,@userid=@userid

				END
			ELSE
				BEGIN
					DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
					DECLARE @current_record_socmed_count INT, @new_record_socmed_count INT, @new_record_phone_count INT

					SELECT @current_record_main_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_CONTACT

					SELECT @new_record_main_count = count(*)
					FROM #_DM_CONTACT

					SELECT @current_record_socmed_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_CONTACT_SOCIAL_MEDIA

					SELECT @new_record_socmed_count = count(*)
					FROM #_DM_CONTACT_SOCIAL_MEDIA

					SELECT @current_record_phone_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_CONTACT_OTHER_PHONE

					SELECT @new_record_phone_count = count(*)
					FROM #_DM_CONTACT_OTHER_PHONE

					SET @current_record_main_count = @tolerance * @current_record_main_count
					SET @current_record_socmed_count = @tolerance * @current_record_socmed_count
					SET @current_record_phone_count = @tolerance * @current_record_phone_count
			
					IF @new_record_main_count >= @current_record_main_count
							AND  @new_record_socmed_count >= @current_record_socmed_count
							AND  @new_record_phone_count >= @current_record_phone_count

					BEGIN
						
							-- Update Main tables _DM_CONTACT in DM_Shadow_Staging and DM_Shadow_Production databases
							SET @fields = 'id,userid,username,lastModified,Create_Datetime,Download_Datetime' +
									',termID, surveyID' +
									',BUILDING,ROOM,OPHONE1,OPHONE2,OPHONE3,MAILBOX' +
									',ADDL_BUILDING,ADDL_ROOM,ADDL_PHONE1,ADDL_PHONE2,ADDL_PHONE3' +
									',ADDRESS_DISPLAY,PHONE_DISPLAY,OFFICE_HOURS,APPT_ONLY,CAMPUS_EMAIL,ADDL_EMAIL,HOMEPAGE_WEB_ADDRESS' +
									',NAME,RELATION,EMERGENCY_PHONE1,EMERGENCY_PHONE2,EMERGENCY_PHONE3,EMERGENCY_PHONE4,EMERGENCY_EMAIL'

							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							    ,@table='_DM_CONTACT'
								,@cols=@fields
								,@userid=NULL

							-- Truncate and Insert into Main tables _DM_CONTACT_OTHER_PHONE in DM_Shadow_Staging and DM_Shadow_Production databases											
							SET @fields = 'id,itemid,USERNAME, lastModified, Create_Datetime,Download_Datetime'+
											',TYPE,PHONE1,PHONE2,PHONE3,PHONE4,SHOW	'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							    ,@table='_DM_CONTACT_OTHER_PHONE'
								,@cols=@fields
								,@userid=NULL

							-- Truncate and Insert into Main tables _DM_CONTACT_SOCIAL_MEDIA in DM_Shadow_Staging and DM_Shadow_Production databases											
							SET @fields = 'id,itemid,USERNAME,lastModified,Create_Datetime,Download_Datetime' + 
											',TYPE,TYPE_OTHER,WEB_ADDRESS,SHOW'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							    ,@table='_DM_CONTACT_SOCIAL_MEDIA'
								,@cols=@fields
								,@userid=NULL

	
						END
					ELSE
						BEGIN
							UPDATE dbo.webservices_requests SET SP_Error='CONTACT Data is too few' WHERE [ID]=@webservices_requests_id		
							RAISERROR('shadow_CONTACT - Data is too few',18,1)
						END
					
				END	

			EXEC sp_releaseapplock 'shadowmaker-CONTACT','Session'; 
		

	END



	DROP TABLE #_DM_CONTACT;
	DROP TABLE #_DM_CONTACT_SOCIAL_MEDIA;
	DROP TABLE #_DM_CONTACT_OTHER_PHONE;

	
END



GO
