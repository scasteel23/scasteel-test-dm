SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/24/2016. worked!
CREATE PROC [dbo].[_Test_Shadow_DEG_COMMITTEE]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'  	  <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-04-24">
	  <Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
		<DEG_COMMITTEE id="133567455232" dmd:originalSource="MANUAL" dmd:created="2016-09-16T18:40:29" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-14T16:06:22" dmd:startDate="2011-01-01" dmd:endDate="2018-02-28">
			<FNAME>Kenny</FNAME>
			<LNAME>Sullivan</LNAME>
			<UIN>888888</UIN>
			<INSTITUTION>Gies Business</INSTITUTION>
			<INSTITUTION_OTHER />
			<DEP>Accountancy</DEP>
			<DEP_OTHER />
			<TYPE>Master''s Thesis</TYPE>
			<TYPE>PhD Final (Dissertation)</TYPE>
			<TYPE>PhD Prelim (Proposal)</TYPE>
			<TYPE_OTHER />
			<ROLE>Chair</ROLE>
			<ROLE>Co-Chair</ROLE>
			<ROLE>Co-Director of Research</ROLE>
			<ROLE>Director of Research</ROLE>
			<ROLE>Other</ROLE>
			<ROLE_OTHER>Committee Auditor</ROLE_OTHER>
			<DTM_START>January</DTM_START>
			<DTY_START>2011</DTY_START>
			<START_START>2011-01-01</START_START>

			<START_END>2011-01-31</START_END>
			<DTM_END>February</DTM_END>
			<DTY_END>2018</DTY_END>
			<END_START>2018-02-01</END_START>
			<END_END>2018-02-28</END_END>

			<DTM_PRELIM_START>February</DTM_PRELIM_START>
			<DTY_PRELIM_START>2016</DTY_PRELIM_START>
			<PRELIM_START_START>2016-02-01</PRELIM_START_START>
			<PRELIM_START_END>2016-02-28</PRELIM_START_END>
			<DTM_PRELIM_END>March</DTM_PRELIM_END>
			<DTY_PRELIM_END>2017</DTY_PRELIM_END>
			<PRELIM_END_START>2017-03-01</PRELIM_END_START>
			<PRELIM_END_END>2017-03-31</PRELIM_END_END>
			<DTM_FINAL_START>February</DTM_FINAL_START>
			<DTY_FINAL_START>2018</DTY_FINAL_START>
			<FINAL_START_START>2018-02-01</FINAL_START_START>
			<FINAL_START_END>2018-02-28</FINAL_START_END>
			<DTM_FINAL_END>May</DTM_FINAL_END>
			<DTY_FINAL_END>2020</DTY_FINAL_END>
			<FINAL_END_START>2020-05-01</FINAL_END_START>
			<FINAL_END_END>2020-05-31</FINAL_END_END>
			<DESC>I am in a Degree Committee, yeah</DESC>
			<TITLE>What A Different a Day Makes</TITLE>
			<PLACEMENT>KPMG</PLACEMENT>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</DEG_COMMITTEE>
			</Record>
		</Data>'
	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_DEG_COMMITTEE @webservices_requests_id=4500,@xml=@responsexml, @userid=NULL,@resync=1

GO
