SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/1/2018: ongoing
CREATE PROC [dbo].[_Test_Shadow_MEDCONT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2018-08-01">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<MEDCONT id="167479912448" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-01T11:03:38" dmd:startDate="2018-02-08" dmd:endDate="2018-02-08">
<TYPE>Newspaper</TYPE>
<TYPE_OTHER />
<TITLE>Droid with hands and legs!</TITLE>
<REPORTER>Mila Kunis</REPORTER>
<NAME>News Gazette</NAME>
<WEB_ADDRESS>https://www.ng.com</WEB_ADDRESS>
<DESC>We have a robot and a droid, why not combine them together?</DESC>
<DTM_DATE>February</DTM_DATE>
<DTD_DATE>8</DTD_DATE>
<DTY_DATE>2018</DTY_DATE>
<DATE_START>2018-02-08</DATE_START>
<DATE_END>2018-02-08</DATE_END>
<INTELLCONT_REF_DSA id="167479912451">
<INTELLCONT id="144216559616" lastModified="2018-07-12T11:17:38" originalSource="IMPORT" startDate="2015-01-01" endDate="2015-12-31">
<CONTYPE>Article, Academic Journal</CONTYPE>
<TITLE>article 6</TITLE>
<STATUS>Under Contract</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<PUBCTYST />
<INVITED>No</INVITED>
<INTELLCONT_AUTH id="144216559617">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME />
<LNAME>Hadi</LNAME>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </INTELLCONT_AUTH>
<DTY_ACC>2015</DTY_ACC>
<ACC_START>2015-01-01</ACC_START>
<ACC_END>2015-12-31</ACC_END>
<PUBLICAVAIL>Yes</PUBLICAVAIL>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</INTELLCONT>
<INTELLCONT_REF>144216559616</INTELLCONT_REF>
</INTELLCONT_REF_DSA>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </MEDCONT>
 </Record>
</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_MEDCONT @webservices_requests_id=1,@xml=@responsexml,@resync=1

	/*
		select * from DM_Shadow_Production.dbo._dm_MEDCONT
		select * from DM_Shadow_Production.dbo._dm_MEDCONT_INTELLCONT_REF_DSA
		select * from webservices_requests order by id asc

	*/


GO
