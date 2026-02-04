SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 7/10/2018
-- NS 10/6/2016 worked, at Carle

CREATE PROC [dbo].[_Test_Shadow_SERVICE_ACADEMIC]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(MAX)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-06">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<SERVICE_ACADEMIC id="166435889152" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-10T13:30:07" dmd:startDate="2016-01-01" dmd:endDate="2019-05-31">
<TYPE>Service at Other Academic Organization</TYPE>
<ROLE>Board of Trustee</ROLE>
<ORG>University of Small Enterprise</ORG>
<ORG_REPORTABLE>University of Small Enterprise</ORG_REPORTABLE>
<CITY>Chicago</CITY>
<STATE>Illinois</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE>University</SCOPE>
<DESC>This is a new university created for Small Enterpreneurships</DESC>
<DTM_START />
<DTY_START>2016</DTY_START>
<START_START>2016-01-01</START_START>
<START_END>2016-12-31</START_END>
<DTM_END>May</DTM_END>
<DTY_END>2019</DTY_END>
<END_START>2019-05-01</END_START>
<END_END>2019-05-31</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
<PERENNIAL>No</PERENNIAL>
 </SERVICE_ACADEMIC>
<SERVICE_ACADEMIC id="134285971456" dmd:lastModified="2018-07-10T13:28:09" dmd:startDate="2015-01-01" dmd:endDate="2016-04-30">
<TYPE>Advisor/Sponsor/Mentor</TYPE>
<ROLE>SBC University Preparation Team</ROLE>
<ORG>SBC University</ORG>
<ORG_REPORTABLE>SBC University</ORG_REPORTABLE>
<CITY>Melbourne</CITY>
<STATE />
<COUNTRY>Australia</COUNTRY>
<SCOPE />
<DESC>this is a prestigious fictional university</DESC>
<DTM_START>January</DTM_START>
<DTY_START>2015</DTY_START>
<START_START>2015-01-01</START_START>
<START_END>2015-01-31</START_END>
<DTM_END>April</DTM_END>
<DTY_END>2016</DTY_END>
<END_START>2016-04-01</END_START>
<END_END>2016-04-30</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>5</WEB_PROFILE_ORDER>
<PERENNIAL>Yes</PERENNIAL>
 </SERVICE_ACADEMIC>
</Record>
</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.Shadow_SERVICE_ACADEMIC @webservices_requests_id=1, @xml=@responsexml, @userid=NULL,@resync=1

GO
