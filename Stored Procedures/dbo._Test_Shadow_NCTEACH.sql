SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/5/2018
CREATE PROC [dbo].[_Test_Shadow_NCTEACH]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(MAX)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	 <Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<NCTEACH id="166264926208" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-05T16:40:16" dmd:startDate="2018-01-01" dmd:endDate="2020-12-31">
<TYPE>Management/Executive Development</TYPE>
<TYPEOTHER />
<AUDIENCE>External to University of Illinois at Urbana-Champaign</AUDIENCE>
<ORG>University of Indonesia</ORG>
<NUMPART>100</NUMPART>
<DESC>Disruptive Agent, Era of Disruption</DESC>
<DTM_START />
<DTY_START>2018</DTY_START>
<START_START>2018-01-01</START_START>
<START_END>2018-12-31</START_END>
<DTM_END />
<DTY_END>2020</DTY_END>
<END_START>2020-01-01</END_START>
<END_END>2020-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </NCTEACH>
 </Record>
</Data>	'
	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_NCTEACH @webservices_requests_id=4433, @xml=@responsexml, @userid=NULL,@resync=1

GO
