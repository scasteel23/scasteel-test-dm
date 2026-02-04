SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/14/2018: new structure of ADMIN screen
-- NS 10/27/2017

CREATE PROC [dbo].[_Test_Shadow_ADMIN]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	-- https://www.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business
	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-07-28">		
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<ADMIN id="143967483904" dmd:originalSource="MANAGE_DATA" dmd:created="2017-03-21T09:15:15" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-14T13:28:47" dmd:startDate="2016-09-01" dmd:endDate="2017-08-31" dmd:primaryKey="2016-2017">
<AC_YEAR>2016-2017</AC_YEAR>
<YEAR_START>2016-09-01</YEAR_START>
<YEAR_END>2017-08-31</YEAR_END>
<ADMIN_DEP id="143967483907" dmd:primaryKey="Business IT Services">
<DEP>Business IT Services</DEP>
</ADMIN_DEP>
<ADMIN_DEP id="143967483909" dmd:primaryKey="Business Career Services">
<DEP>Business Career Services</DEP>
</ADMIN_DEP>
<ADMIN_DEP id="143967483911" dmd:primaryKey="Accountancy">
<DEP>Accountancy</DEP>
</ADMIN_DEP>
<NPRESP>Administration</NPRESP>
<NPRESP>Doctoral Level Teaching/Mentoring</NPRESP>
<NPRESP>Executive Education</NPRESP>
<DEDMISS>100</DEDMISS>
<QUALIFICATION>Scholarly Academic</QUALIFICATION>
<QUALIFICATION_BASIS>not sure what it is</QUALIFICATION_BASIS>
<AACSBSUFF>Participating</AACSBSUFF>
<JOINT_APPOINTMENT>Yes</JOINT_APPOINTMENT>
 </ADMIN>
<ADMIN id="131001090048" dmd:originalSource="MANUAL" dmd:created="2016-07-21T08:25:34" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-14T13:28:41" dmd:startDate="2015-09-01" dmd:endDate="2016-08-31" dmd:primaryKey="2015-2016">
<AC_YEAR>2015-2016</AC_YEAR>
<YEAR_START>2015-09-01</YEAR_START>
<YEAR_END>2016-08-31</YEAR_END>
<ADMIN_DEP id="131001090049" dmd:primaryKey="Accountancy">
<DEP>Accountancy</DEP>
</ADMIN_DEP>
<ADMIN_DEP id="131001090051" dmd:primaryKey="Business IT Services">
<DEP>Business IT Services</DEP>
</ADMIN_DEP>
<ADMIN_DEP id="131001090053" dmd:primaryKey="Business Administration">
<DEP>Business Administration</DEP>
</ADMIN_DEP>
<NPRESP>Administration</NPRESP>
<NPRESP>Doctoral Level Teaching/Mentoring</NPRESP>
<NPRESP>Executive Education</NPRESP>
<NPRESP>Master''s Level Teaching</NPRESP>
<DEDMISS />
<QUALIFICATION />
<QUALIFICATION_BASIS />
<AACSBSUFF />
<JOINT_APPOINTMENT />
 </ADMIN>
 </Record>
	</Data>'


	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_ADMIN 0, @xml=@responsexml, @userid=NULL,@resync=1

GO
