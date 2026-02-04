SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/2/2018 redone
-- NS 10/6/2016 at Carle

CREATE PROC [dbo].[_Test_Shadow_SERVICE_PROFESSIONAL]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(MAX)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-06">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<SERVICE_PROFESSIONAL id="134117332992" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-30T17:50:31" dmd:startDate="2016-01-01" dmd:endDate="2016-12-31">
<TYPE>EDITORIAL BOARDS - Editor or Co-Editor</TYPE>
<ROLE>Editorial Board</ROLE>
<ORG>CACM</ORG>
<ORG_REPORTABLE>CACM</ORG_REPORTABLE>
<CITY>Sacramento</CITY>
<STATE>California</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE_LOCALE>International</SCOPE_LOCALE>
<CLASSIFICATION>Basic or Discovery Scholarship</CLASSIFICATION>
<DESC>Nano superscale GPS navigation</DESC>
<DTM_START />
<DTY_START />
<START_START />
<START_END />
<DTM_END />
<DTY_END>2016</DTY_END>
<END_START>2016-01-01</END_START>
<END_END>2016-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER>6</WEB_PROFILE_ORDER>
<PERENNIAL>Yes</PERENNIAL>
<FSDB_CURRENT />
 </SERVICE_PROFESSIONAL>
 <SERVICE_PROFESSIONAL id="134117300224" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-30T17:50:39" dmd:startDate="2003-01-01" dmd:endDate="2006-12-31">
<TYPE>CONFERENCES - Conference Moderator</TYPE>
<ROLE>Head Moderator</ROLE>
<ORG>Red Cross Champaign</ORG>
<ORG_REPORTABLE>Red Cross Big Data</ORG_REPORTABLE>
<CITY>Urbana</CITY>
<STATE>Illinois</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE_LOCALE>Regional</SCOPE_LOCALE>
<CLASSIFICATION>Teaching and Learning Scholarship</CLASSIFICATION>
<DESC>member get member</DESC>
<DTM_START />
<DTY_START>2003</DTY_START>
<START_START>2003-01-01</START_START>
<START_END>2003-12-31</START_END>
<DTM_END />
<DTY_END>2006</DTY_END>
<END_START>2006-01-01</END_START>
<END_END>2006-12-31</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>10</WEB_PROFILE_ORDER>
<PERENNIAL />
<FSDB_CURRENT />
 </SERVICE_PROFESSIONAL>
 </Record>
</Data>
 '

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.Shadow_SERVICE_PROFESSIONAL @webservices_requests_id=1,@xml=@responsexml, @userid=NULL,@resync=1

GO
