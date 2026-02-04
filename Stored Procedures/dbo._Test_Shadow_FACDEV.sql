SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/9/2016

CREATE PROC [dbo].[_Test_Shadow_FACDEV]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
		<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<FACDEV id="132759838720" dmd:lastModified="2016-08-30T16:59:28" dmd:startDate="2013-01-01" dmd:endDate="2014-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>12</CHOURS>
			<DESC>import test 1</DESC>
			
			<CPE>Yes</CPE>
			<DTY_START>2013</DTY_START>
			<START_START>2013-01-01</START_START>
			<START_END>2013-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<FACDEV id="130927077376" dmd:lastModified="2016-08-30T16:57:31" dmd:startDate="2017-01-01" dmd:endDate="2018-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>16</CHOURS>
			<DESC>import test 1</DESC>
			
			<CPE>Yes</CPE>
			<DTY_START>2017</DTY_START>
			<START_START>2017-01-01</START_START>
			<START_END>2017-12-31</START_END>
			<DTY_END>2018</DTY_END>
			<END_START>2018-01-01</END_START>
			<END_END>2018-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
		<FACDEV id="132759840768" dmd:lastModified="2016-08-30T16:59:28" dmd:startDate="2015-01-01" dmd:endDate="2016-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>12</CHOURS>
			<DESC>import test 1</DESC>
		
			<CPE>Yes</CPE>
			<DTY_START>2015</DTY_START>
			<START_START>2015-01-01</START_START>
			<START_END>2015-12-31</START_END>
			<DTY_END>2016</DTY_END>
			<END_START>2016-01-01</END_START>
			<END_END>2016-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
	</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_FACDEV @webservices_requests_id=1, @xml=@responsexml, @userid=NULL,@resync=1

GO
