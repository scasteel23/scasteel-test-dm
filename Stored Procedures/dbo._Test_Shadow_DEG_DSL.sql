SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/20/2018
CREATE PROC [dbo].[_Test_Shadow_DEG_DSL]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	/*
		cannot use & on the XML data!

		TRUNCATE TABLE DM_Shadow_Staging.dbo._DM_DSL_LEVELS
		TRUNCATE TABLE DM_Shadow_Production.dbo._DM_DSL_LEVELS
		TRUNCATE TABLE DM_Shadow_Staging.dbo._DM_DSL
		TRUNCATE TABLE DM_Shadow_Production.dbo._DM_DSL

	*/

	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<DSL id="169824608256" dmd:originalSource="MANUAL" dmd:created="2018-09-20T10:44:56" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-20T10:44:57" dmd:startDate="2017-10-01" dmd:endDate="2018-12-31">
<TYPE>Academic Advisor or Mentor</TYPE>
<TYPE_OTHER>No other</TYPE_OTHER>
<TITLE>Consulting with Digital Courses Thesis</TITLE>
<PROGRAM>Dissertation</PROGRAM>
<LEVELS>Doctoral</LEVELS>
<LEVELS>Undergraduate</LEVELS>
<SPONSOR>Gies Business</SPONSOR>
<ORG>History</ORG>
<INSTITUTION>Caterpillar</INSTITUTION>
<SPONSOR_OTHER>no other sponsor</SPONSOR_OTHER>
<DESC>Supervise Graduate Research Accompany International Trip IBM All Users for a Schema and Index Entry Retrieve users with access to University data in the College of Business</DESC>
<DTM_START>October</DTM_START>
<DTY_START>2017</DTY_START>
<START_START>2017-10-01</START_START>
<START_END>2017-10-31</START_END>
<DTM_END>December</DTM_END>
<DTY_END>2018</DTY_END>
<END_START>2018-12-01</END_START>
<END_END>2018-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </DSL>
 </Record>
<Record userId="1910556" username="busfac1" termId="6117" dmd:surveyId="17699128">
<DSL id="164584628224" dmd:originalSource="MANAGE_DATA" dmd:created="2018-05-30T14:45:00" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-08-06T19:31:28" dmd:startDate="2017-01-01" dmd:endDate="2017-12-31">
<TYPE>Accompany International Trip</TYPE>
<TYPE_OTHER />
<TITLE>China Immersion Trip</TITLE>
<PROGRAM />
<LEVELS>Undergraduate</LEVELS>
<SPONSOR>Gies Business</SPONSOR>
<ORG>Accountancy</ORG>
<INSTITUTION />
<SPONSOR_OTHER />
<DESC />
<DTM_START />
<DTY_START />
<START_START />
<START_END />
<DTM_END />
<DTY_END>2017</DTY_END>
<END_START>2017-01-01</END_START>
<END_END>2017-12-31</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
 </DSL></Record></Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_DSL @webservices_requests_id=4500,@xml=@responsexml, @userid=NULL,@resync=1

GO
