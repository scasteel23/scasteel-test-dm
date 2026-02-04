SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/3/2018: renamed from INNVATIONS to CURRICULUM, but no need to retest
-- NS 10/27/2016: It worked!

CREATE PROC [dbo].[_Test_Shadow_CURRICULUM]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<CURRICULUM id="167708702720" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-03T14:48:02" dmd:startDate="2017-05-01">
<TYPE>Revise Existing Course</TYPE>
<TYPE_OTHER />
<ORG>At Illinois, Outside Gies Business</ORG>
<ORG_OTHER>Social Works</ORG_OTHER>
<TITLE>How to approach the homeless without emotionless</TITLE>
<EVENT>Park gathering</EVENT>
<PRES_TITLE>Social works around us</PRES_TITLE>
<DESC>This is one of the park programs</DESC>
<DTM_START>May</DTM_START>
<DTY_START>2017</DTY_START>
<START_START>2017-05-01</START_START>
<START_END>2017-05-31</START_END>
<DTM_END />
<DTY_END />
<END_START />
<END_END />
<WEB_PROFILE>Yes</WEB_PROFILE>
 </CURRICULUM>
<CURRICULUM id="167708678144" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-03T14:48:53" dmd:startDate="1999-01-01" dmd:endDate="2003-03-31">
<TYPE>New Course</TYPE>
<TYPE_OTHER />
<ORG>Gies Business</ORG>
<ORG_OTHER />
<TITLE>UISES</TITLE>
<EVENT>Classroom seminar</EVENT>
<PRES_TITLE>30 year UISES</PRES_TITLE>
<DESC>History of UISES</DESC>
<DTM_START>January</DTM_START>
<DTY_START>1999</DTY_START>
<START_START>1999-01-01</START_START>
<START_END>1999-01-31</START_END>
<DTM_END>March</DTM_END>
<DTY_END>2003</DTY_END>
<END_START>2003-03-01</END_START>
<END_END>2003-03-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </CURRICULUM>
 </Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_CURRICULUM @xml=@responsexml, @userid=NULL,@resync=1

GO
