SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 10/31/2016: Worked!
CREATE PROC [dbo].[_Test_Shadow_CONGRANT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-28">
<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">

<CONGRANT id="134301261824" dmd:lastModified="2016-10-21T14:59:56">
<TITLE>Dummy Grant Proposal</TITLE>
<SPONORG>Me</SPONORG>
<CONGRANT_INVEST id="134301261825">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="134301261827">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="134301261828">
<FACULTY_NAME/>
<FNAME>Bugs</FNAME>
<MNAME/>
<LNAME>Bunny</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>
<AMOUNT>10</AMOUNT>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER/>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>

<CONGRANT id="135061225472" dmd:lastModified="2016-10-24T12:36:40" dmd:startDate="2014-01-01" dmd:endDate="2016-12-31">
<TITLE>Map Entrepreneurship Program Distribution</TITLE>
<STATUS>Awaiting Decision</STATUS>
<SPONORG>Kauffman Foundation</SPONORG>
<CONGRANT_INVEST id="135061225473">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE/>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="135061225475">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>
<AMOUNT>12000</AMOUNT>
<CONTYPE>Contributions to Practice</CONTYPE>
<DTY_START>2014</DTY_START>
<START_START>2014-01-01</START_START>
<START_END>2014-12-31</START_END>
<DTY_END>2016</DTY_END>
<END_START>2016-01-01</END_START>
<END_END>2016-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>



</Record>
</Data>'
	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_CONGRANT @webservices_requests_id=4428, @xml=@responsexml, @userid=NULL,@resync=1

GO
