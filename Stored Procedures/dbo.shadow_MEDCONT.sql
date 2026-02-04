SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- NS 8/2/2018: done tested

/*
	Manual run to shadow individual MEDCONT screen
	EXEC dbo.webservices_initiate @screen='MEDCONT'
	EXEC dbo.webservices_run_DTSX
*/


CREATE PROCEDURE [dbo].[shadow_MEDCONT] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all MEDCONT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/MEDCONT
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:nhadi/MEDCONT
	-- XML Sample:
/*
		
	<Data dmd:date="2018-08-01">
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
	<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
	<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />

	<MEDCONT id="167479912448" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-01T11:03:38" dmd:startDate="2018-02-08" dmd:endDate="2018-02-08">
		<TYPE>Newspaper</TYPE>
		<TYPE_OTHER />
		<TITLE>Droid with hands and legs!</TITLE>
		<REPORTER>Mila Kunis</REPORTER>
		<NAME>News Gazette</NAME>
		<WEB_ADDRESS>https://www.ng.com</WEB_ADDRESS>
		<DESC>We have a robot and a droid, why not combine them together?</DESC>
		<DTM_DATE>February</DTM_DATE>
		<DTD_DATE>8</DTD_DATE>
		<DTY_DATE>2018</DTY_DATE>
		<DATE_START>2018-02-08</DATE_START>
		<DATE_END>2018-02-08</DATE_END>
		
		<INTELLCONT_REF_DSA id="167479912449">
			<INTELLCONT id="144157110272" lastModified="2018-07-12T11:17:38" originalSource="MANUAL" startDate="2001-01-01" endDate="2001-12-31"></INTELLCONT>
			<INTELLCONT_REF>144157110272</INTELLCONT_REF>
		</INTELLCONT_REF_DSA>
		
		<INTELLCONT_REF_DSA id="167479912451">
			<INTELLCONT id="144216559616" lastModified="2018-07-12T11:17:38" originalSource="IMPORT" startDate="2015-01-01" endDate="2015-12-31">
				<CONTYPE>Article, Academic Journal</CONTYPE>
				<TITLE>article 6</TITLE>
				<STATUS>Under Contract</STATUS>
				<JOURNAL_REF>-1</JOURNAL_REF>
				<PUBCTYST />
				<INVITED>No</INVITED>
				<INTELLCONT_AUTH id="144216559617">
					<FACULTY_NAME>1791140</FACULTY_NAME>
					<FNAME>Nursalim</FNAME>
					<MNAME />
					<LNAME>Hadi</LNAME>
					<WEB_PROFILE>Yes</WEB_PROFILE>
				</INTELLCONT_AUTH>
				<DTY_ACC>2015</DTY_ACC>
				<ACC_START>2015-01-01</ACC_START>
				<ACC_END>2015-12-31</ACC_END>
				<PUBLICAVAIL>Yes</PUBLICAVAIL>
				<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
			</INTELLCONT>
			<INTELLCONT_REF>144216559616</INTELLCONT_REF>
		</INTELLCONT_REF_DSA>
		<WEB_PROFILE>Yes</WEB_PROFILE>
		 </MEDCONT>
</Record>
 </DATA>
		
	>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	Parse XML nested <MEDCONT>
	*/

	DECLARE @prefix varchar(1000)
	SELECT @prefix = SP_ERROR FROM dbo.webservices_requests WHERE [ID]=@webservices_requests_id		
	SET @prefix = @prefix + '- shadow_MEDCONT '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		
		ISNULL(Item.value('(TYPE/text())[1]','varchar(60)'),'')[TYPE],
		ISNULL(Item.value('(TYPE_OTHER/text())[1]','varchar(60)'),'')TYPE_OTHER,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(600)'),'')TITLE,
		ISNULL(Item.value('(REPORTER/text())[1]','varchar(600)'),'')REPORTER,
		ISNULL(Item.value('(NAME/text())[1]','varchar(600)'),'')NAME,
		ISNULL(Item.value('(WEB_ADDRESS/text())[1]','varchar(200)'),'')WEB_ADDRESS,

		ISNULL(Item.value('(DESC/text())[1]','varchar(2000)'),'')[DESC],
		ISNULL(Item.value('(DTM_DATE/text())[1]','varchar(2)'),'')DTM_DATE,
		ISNULL(Item.value('(DTD_DATE/text())[1]','varchar(12)'),'')DTD_DATE,
		ISNULL(Item.value('(DTY_DATE/text())[1]','varchar(4)'),'')DTY_DATE,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,

		getdate() as Create_Datetime,
		getdate() as Download_Datetime			
			
	INTO #_DM_MEDCONT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./MEDCONT')Items(Item);
	
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT MEDCONT.value('@id','bigint')id,
		REC.value('@userId','bigint')userid,
		MEDCONT.value('@dmd:lastModified','date')lastModified,
		REC.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
			
		ROW_NUMBER()OVER(PARTITION BY MEDCONT ORDER BY Item)sequence,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_MEDCONT_INTELLCONT_REF_DSA
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./MEDCONT')MEDCONTs(MEDCONT)
		CROSS APPLY MEDCONTs.MEDCONT.nodes('./INTELLCONT_REF_DSA')DSAs(DSA)
		CROSS APPLY DSAs.DSA.nodes('./INTELLCONT')Items(Item);


	--select * from #_DM_MEDCONT
	--select * from #_DM_MEDCONT_INTELLCONT_REF_DSA

	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_MEDCONT) < 1  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': MEDCONT has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('MEDCONT has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-MEDCONT2','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-MEDCONT2 Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadowmaker-MEDCONT2 Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE	BEGIN 
		
			IF @userid is not null
					BEGIN
						-- Update records of @userid at Main tables _DM_MEDCONT in DM_Shadow_Staging and DM_Shadow_Production databases
						-- Transaction error can result from the list of the @fields does not match table schema
						-- MUST use field names that is similar with system names with bracket [] in @fields
						SET @fields = 'userid,id,lastModified,Create_Datetime,Download_Datetime,USERNAME,TYPE,TYPE_OTHER,TITLE,REPORTER' +
									 ',NAME,WEB_ADDRESS,[DESC],DTM_DATE,DTD_DATE,DTY_DATE' +				
									 ',WEB_PROFILE'
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_MEDCONT'
							,@cols=@fields
							,@userid=@userid				

						-- Update records of @userid at relational tables _DM_MEDCONT_INTELLCONT_REF_DSA in DM_Shadow_Staging and DM_Shadow_Production databases		    					
						SET @fields = 'id,itemid,lastModified,Create_Datetime,Download_Datetime,sequence'
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_MEDCONT_INTELLCONT_REF_DSA'
							,@cols=@fields
							,@userid=@userid

					END
			ELSE	
				BEGIN
			
					DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
					DECLARE @current_record_languages_count INT, @new_record_languages_count INT 

					SELECT @current_record_main_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_MEDCONT

					SELECT @new_record_main_count = count(*)
					FROM #_DM_MEDCONT

					SELECT @current_record_languages_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_MEDCONT_INTELLCONT_REF_DSA

					SELECT @new_record_languages_count = count(*)
					FROM #_DM_MEDCONT_INTELLCONT_REF_DSA

				
					SET @current_record_main_count = @tolerance * @current_record_main_count
					SET @current_record_languages_count = @tolerance * @current_record_languages_count
			
					IF @new_record_main_count >= @current_record_main_count
							AND  @new_record_languages_count >= @current_record_languages_count

							BEGIN

								BEGIN TRANSACTION [twotables]
								BEGIN TRY
								-- Update Main tables _DM_MEDCONT in DM_Shadow_Staging and DM_Shadow_Production databases
								SET @fields = 'userid,id,lastModified,Create_Datetime,Download_Datetime,USERNAME,TYPE,TYPE_OTHER,TITLE,REPORTER' +
									 ',NAME,WEB_ADDRESS,[DESC],DTM_DATE,DTD_DATE,DTY_DATE' +				
									 ',WEB_PROFILE'
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_MEDCONT'
									,@cols=@fields
									,@userid=NULL

								-- Truncate and Insert into Main tables _DM_MEDCONT_INTELLCONT_REF_DSA in DM_Shadow_Staging and DM_Shadow_Production databases											
								SET @fields = 'id,itemid,lastModified,Create_Datetime,Download_Datetime,sequence '
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_MEDCONT_INTELLCONT_REF_DSA'
									,@cols=@fields
									,@userid=NULL

								COMMIT TRANSACTION [twotables]
								END TRY

								BEGIN CATCH
									DECLARE @emsg varchar(MAX)
									SET @emsg = LEFT(ERROR_MESSAGE(), 500)
									UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': ' + @emsg WHERE [ID]=@webservices_requests_id	
								END CATCH

							END
						ELSE
							BEGIN
								UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadow_MEDCONT Data is too few' WHERE [ID]=@webservices_requests_id		
								EXEC sp_releaseapplock 'shadowmaker-MEDCONT2','Session'; 
								RAISERROR('Data is too few',18,1)
							END
					
				END
			EXEC sp_releaseapplock 'shadowmaker-MEDCONT2','Session'; 
		END

	END

	UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadow_MEDCONT Done' WHERE [ID]=@webservices_requests_id		


	
	DROP TABLE #_DM_MEDCONT;
	DROP TABLE #_DM_MEDCONT_INTELLCONT_REF_DSA;

END



GO
