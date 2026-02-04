SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 10/5/2016 at Carle

CREATE PROC [dbo].[_Test_Shadow_SERVICE_COMMITTEE]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(MAX)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-05">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
<SERVICE_COMMITTEE id="134266566656" dmd:lastModified="2016-10-05T18:39:07" dmd:startDate="2015-01-01" dmd:endDate="2015-12-31">
<TYPE>
Ad Hoc College Committee (In College of Business, UIUC)
</TYPE>
<ORG>New Hire Committee for Undergraduate Affairs</ORG>
<ROLE>Member</ROLE>
<SUPERVISION>Yes</SUPERVISION>
<READING>No</READING>
<INIT_EMPLOYMENT>Undergraduate Affairs</INIT_EMPLOYMENT>
<DESC>This is for John Weible position</DESC>
<DEP>Undergraduate Affairs</DEP>
<YR_START/>
<START_START/>
<START_END/>
<YR_END>2015</YR_END>
<END_START>2015-01-01</END_START>
<END_END>2015-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
</SERVICE_COMMITTEE>
<SERVICE_COMMITTEE id="134266568704" dmd:lastModified="2016-10-05T18:39:57" dmd:startDate="2012-01-01" dmd:endDate="2014-12-31">
<TYPE>University Committee (In UIUC)</TYPE>
<ORG>IT PRO</ORG>
<ROLE>Co-Chair</ROLE>
<SUPERVISION>Yes</SUPERVISION>
<READING>No</READING>
<INIT_EMPLOYMENT>None</INIT_EMPLOYMENT>
<DESC>a ajdkida lajdlask dhjas</DESC>
<DEP>Illinois Business Consulting</DEP>
<YR_START>2012</YR_START>
<START_START>2012-01-01</START_START>
<START_END>2012-12-31</START_END>
<YR_END>2014</YR_END>
<END_START>2014-01-01</END_START>
<END_END>2014-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
</SERVICE_COMMITTEE>
</Record>
</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.Shadow_SERVICE_COMMITTEE @xml=@responsexml, @userid=NULL,@resync=1

GO
