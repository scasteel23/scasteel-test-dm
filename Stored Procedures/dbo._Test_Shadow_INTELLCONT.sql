SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/2/2018: dropped/renamed/added fields
-- NS 3/22/2017: 
CREATE PROC [dbo].[_Test_Shadow_INTELLCONT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-02-28">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<INTELLCONT id="138778734592" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-02T16:36:39" dmd:startDate="2016-03-01" dmd:endDate="2016-03-31">
<CONTYPE>Article, Other</CONTYPE>
<TITLE>This is a really long title full of words whose only purpose is to fill space</TITLE>
<STATUS>Published</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<JOURNAL id="138778734596"></JOURNAL>
<PUBLISHER />
<PUBCTYST>Atlantis</PUBCTYST>
<VOLUME>23</VOLUME>
<ISSUE>Spring</ISSUE>
<PAGENUM>334-367</PAGENUM>
<REVISED />
<INVITED />
<CLASSIFICATION />
<INTELLCONT_AUTH id="138778734593"></INTELLCONT_AUTH>
<INTELLCONT_AUTH id="138778734595"></INTELLCONT_AUTH>
<EDITORS />
<DTM_EXPSUB />
<DTY_EXPSUB />
<EXPSUB_START />
<EXPSUB_END />
<DTM_SUB />
<DTY_SUB />
<SUB_START />
<SUB_END />
<DTM_ACC />
<DTY_ACC />
<ACC_START />
<ACC_END />
<DTM_PUB>March</DTM_PUB>
<DTD_PUB />
<DTY_PUB>2016</DTY_PUB>
<PUB_START>2016-03-01</PUB_START>
<PUB_END>2016-03-31</PUB_END>
<DESC />
<SCOPE_LOCALE />
<PUBLICAVAIL />
<ABSTRACT />
<WEB_ADDRESS />
<SSRN />
<DOI />
<ISBNISSN />
<USER_REFERENCE_CREATOR>No</USER_REFERENCE_CREATOR>
 </INTELLCONT>
<INTELLCONT id="144216559616" dmd:originalSource="IMPORT" dmd:lastModified="2018-07-12T11:17:38" dmd:startDate="2015-01-01" dmd:endDate="2015-12-31">
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
</Record>
</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_INTELLCONT @webservices_requests_id=1,@xml=@responsexml,@resync=1


GO
