SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/9/2016

CREATE PROC [dbo].[_Test_Shadow_MEMBER]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1940574" username="halmeida" termId="6117" dmd:surveyId="17825316">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/>
		<MEMBER id="130779779072" dmd:lastModified="2016-07-13T22:45:21" dmd:startDate="2010-01-01" dmd:endDate="2014-12-31">
			<NAME>National Bureau of Economic Research</NAME>
			<ORGABBR/>
			<LEADERSHIP>Research Associate</LEADERSHIP>
			<SCOPE/>
			<DESC/>
			<DTY_START>2010</DTY_START>
			<START_START>2010-01-01</START_START>
			<START_END>2010-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
		<MEMBER id="130779783168" dmd:lastModified="2016-07-13T22:45:45" dmd:startDate="2005-01-01" dmd:endDate="2010-12-31">
			<NAME>National Bureau of Economic Research</NAME>
			<ORGABBR/>
			<LEADERSHIP>Faculty Research Fellow</LEADERSHIP>
			<SCOPE/>
			<DESC/>
			<DTY_START>2005</DTY_START>
			<START_START>2005-01-01</START_START>
			<START_END>2005-12-31</START_END>
			<DTY_END>2010</DTY_END>
			<END_START>2010-01-01</END_START>
			<END_END>2010-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
	</Record>
	<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<MEMBER id="126744752128" dmd:lastModified="2016-06-29T12:06:30">
			<NAME>Org 1</NAME>
			<ORGABBR/>
			<LEADERSHIP>King</LEADERSHIP>
			<SCOPE/>
			<DESC/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<MEMBER id="130926909440" dmd:lastModified="2016-07-19T09:08:14" dmd:startDate="1990-01-01">
			<NAME>International Eletrical and Electronics Egineers</NAME>
			<ORGABBR>IEEE</ORGABBR>
			<LEADERSHIP>Member</LEADERSHIP>
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTY_START>1990</DTY_START>
			<START_START>1990-01-01</START_START>
			<START_END>1990-12-31</START_END>
			<DTY_END/>
			<END_START></END_START>
			<END_END></END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
	</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_MEMBER @xml=@responsexml, @userid=NULL,@resync=1

GO
