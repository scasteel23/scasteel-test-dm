SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/9/2016
CREATE PROC [dbo].[_Test_Shadow_PASTHIST]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1940574" username="halmeida" termId="6117" dmd:surveyId="17825316">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/>
		<PASTHIST id="130779676672" dmd:lastModified="2016-07-13T22:28:31" dmd:startDate="2011-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Stanley C. and Joan J. Golder Distinguished Chair in Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2011</DTY_START>
			<START_START>2011-01-01</START_START>
			<START_END>2011-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779680768" dmd:lastModified="2016-07-13T22:29:24" dmd:startDate="2009-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2009</DTY_START>
			<START_START>2009-01-01</START_START>
			<START_END>2009-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779682816" dmd:lastModified="2016-07-13T22:29:45" dmd:startDate="2008-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Director of the Finance PhD program</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2008</DTY_START>
			<START_START>2008-01-01</START_START>
			<START_END>2008-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779686912" dmd:lastModified="2016-07-13T22:30:05" dmd:startDate="2007-01-01" dmd:endDate="2009-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Associate Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2007</DTY_START>
			<START_START>2007-01-01</START_START>
			<START_END>2007-12-31</START_END>
			<DTY_END>2009</DTY_END>
			<END_START>2009-01-01</END_START>
			<END_END>2009-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779752448" dmd:lastModified="2016-07-13T22:43:14" dmd:startDate="2007-01-01" dmd:endDate="2008-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>New York University</ORG>
			<DEP>Stern School of Business</DEP>
			<TITLE>Associate Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2007</DTY_START>
			<START_START>2007-01-01</START_START>
			<START_END>2007-12-31</START_END>
			<DTY_END>2008</DTY_END>
			<END_START>2008-01-01</END_START>
			<END_END>2008-12-31</END_END>
			<CITY/>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
	</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_PASTHIST @xml=@responsexml, @userid=NULL,@resync=1

GO
