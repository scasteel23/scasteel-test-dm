SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/2/2018: Added COUNTRY
-- NS 8/3/2017: Added CAMPUS field
-- NS 9/9/22016: Adjusted fields to DM Business instance: Worked!
--				 Get XML data from the downloader (SSIS package) insert into _DM_EDUCATION table

/*
	Manual run to shadow individual EDUCATION screen
	EXEC dbo.webservices_initiate @screen='EDUCATION'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_EDUCATION] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all EDUCATION data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/EDUCATION
	-- Parse the incoming XML
	/*
		XML Sample
		<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<EDUCATION id="126368507904" dmd:lastModified="2016-06-21T14:04:34" dmd:startDate="2005-01-01" dmd:endDate="2005-12-31">
			<LEVEL>Bachelors</LEVEL>
			<NAME>BS</NAME>
			<SCHOOL>Coolige</SCHOOL>
			<CAMPUS/>
			<LOCATION/>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST/>
			<YR_COMP>2005</YR_COMP>
			<COMP_START>2005-01-01</COMP_START>
			<COMP_END>2005-12-31</COMP_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
		<EDUCATION id="128304977920" dmd:lastModified="2016-05-05T15:02:34" dmd:startDate="1997-01-01" dmd:endDate="1997-12-31">
			<LEVEL>Bachelors</LEVEL>
			<NAME>BS in Computer Science</NAME>
			<SCHOOL>University of Illinois</SCHOOL>
			<CAMPUS/>
			<LOCATION>Urbana-Champaign</LOCATION>
			<COUNTRY>USA</COUNTRY>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST>No</HIGHEST>
			<YR_COMP>1997</YR_COMP>
			<COMP_START>1997-01-01</COMP_START>
			<COMP_END>1997-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
		<EDUCATION id="130107848704" dmd:lastModified="2016-06-20T10:16:53" dmd:startDate="1910-01-01" dmd:endDate="1910-12-31">
			<LEVEL>Others</LEVEL>
			<NAME>Celcius</NAME>
			<SCHOOL>Weather Institute</SCHOOL>
			<LOCATION/>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST/>
			<YR_COMP>1910</YR_COMP>
			<COMP_START>1910-01-01</COMP_START>
			<COMP_END>1910-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<EDUCATION id="130842980352" dmd:lastModified="2016-07-16T14:09:18" dmd:startDate="1995-01-01" dmd:endDate="1995-12-31">
			<LEVEL>Doctoral</LEVEL>
			<NAME>PhD</NAME>
			<SCHOOL>University of Illinois</SCHOOL>
			<LOCATION>Urbana-Champaign</LOCATION>
			<COUNTRY>USA</COUNTRY>
			<MAJOR>Computer Science</MAJOR>
			<FIELDS>Operating Systems</FIELDS>
			<SUPPAREA>Fault Tolerant</SUPPAREA>
			<DISSTITLE>Fault Tolerant Distributed Virtual Memory</DISSTITLE>
			<DISSAREA>Distributed System, Fault Tolerant</DISSAREA>
			<DISSADVISOR>Prof. Roy H. Campbell</DISSADVISOR>
			<DISTINCTION/>
			<HIGHEST>Yes</HIGHEST>
			<YR_COMP>1995</YR_COMP>
			<COMP_START>1995-01-01</COMP_START>
			<COMP_END>1995-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</EDUCATION>
		<EDUCATION id="131916242944" dmd:lastModified="2016-08-12T10:54:59" dmd:startDate="1986-01-01" dmd:endDate="1986-12-31">
			<LEVEL>Bachelors</LEVEL>
			<NAME>Sarjana Teknik</NAME>
			<SCHOOL>Bandung Institute of Technology</SCHOOL>
			<LOCATION>Bandung, Indonesia</LOCATION>
			<MAJOR>Computer Science</MAJOR>
			<FIELDS>Image Processing</FIELDS>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST>No</HIGHEST>
			<YR_COMP>1986</YR_COMP>
			<COMP_START>1986-01-01</COMP_START>
			<COMP_END>1986-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
		</EDUCATION>
	</Record>
	*/



	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,

		ISNULL(Item.value('(LEVEL/text())[1]','varchar(30)'),'')[LEVEL],
		ISNULL(Item.value('(NAME/text())[1]','varchar(100)'),'')NAME,
		ISNULL(Item.value('(SCHOOL/text())[1]','varchar(200)'),'')SCHOOL,
		ISNULL(Item.value('(LOCATION/text())[1]','varchar(200)'),'')LOCATION,
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		ISNULL(Item.value('(CAMPUS/text())[1]','varchar(200)'),'')CAMPUS,
		ISNULL(Item.value('(MAJOR/text())[1]','varchar(100)'),'')MAJOR,
		ISNULL(Item.value('(FIELDS/text())[1]','varchar(200)'),'')FIELDS,
		ISNULL(Item.value('(SUPPAREA/text())[1]','varchar(200)'),'')SUPPAREA,
		ISNULL(Item.value('(DISSTITLE/text())[1]','varchar(400)'),'')DISSTITLE,
		ISNULL(Item.value('(DISSAREA/text())[1]','varchar(200)'),'')DISSAREA,
		ISNULL(Item.value('(DISSADVISOR/text())[1]','varchar(400)'),'')DISSADVISOR,
		ISNULL(Item.value('(DISTINCTION/text())[1]','varchar(100)'),'')DISTINCTION,
		ISNULL(Item.value('(HIGHEST/text())[1]','varchar(3)'),'')HIGHEST,
		ISNULL(Item.value('(YR_COMP/text())[1]','varchar(4)'),'')YR_COMP,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,
		Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER
	INTO #_DM_EDUCATION
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./EDUCATION')Items(Item);
	
	ALTER TABLE #_DM_EDUCATION ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_EDUCATION SET Download_Datetime=getdate();

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_EDUCATION)<2 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='EDUCATION has no data' WHERE [ID]=@webservices_requests_id	
			RAISERROR('EDUCATION has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-education','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0
				BEGIN
					PRINT 'shadowmaker-EDUCATION Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-EDUCATION Import Locked' WHERE [ID]=@webservices_requests_id	
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,LEVEL,NAME,SCHOOL,LOCATION,COUNTRY,CAMPUS,MAJOR,FIELDS,SUPPAREA,DISSTITLE' +
								 ',DISSAREA,DISSADVISOR,DISTINCTION,HIGHEST,YR_COMP,WEB_PROFILE,WEB_PROFILE_ORDER'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_EDUCATION'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-education','Session';
				END
		END
	DROP TABLE #_DM_EDUCATION;

	
END



GO
