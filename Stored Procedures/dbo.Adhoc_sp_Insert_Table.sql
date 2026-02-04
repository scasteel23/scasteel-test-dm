SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Adhoc_sp_Insert_Table] 
AS 
BEGIN
	-- GET all EDUCATION data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/EDUCATION
	-- Parse the incoming XML
	/*
		<journals name="Academy of Management Journal">142384445440</journals>
<journals name="Academy of Management Review">144211447808</journals>
<journals name="Accounting Horizons">152044609536</journals>
<journals name="Accounting, Organizations and Society">142384447488</journals>
<journals name="Actuarial Review">142384449536</journals>
<journals name="Administrative Science Quarterly">144211451904</journals>
<journals name="Auditing: A Journal of Practice and Theory">152044670976</journals>
<journals name="Behavioral Research in Accounting">152044685312</journals>
<journals name="Contemporary Accounting Research">152044693504</journals>
<journals name="Group Decision and Negotiation">144211480576</journals>
<journals name="Information Systems Research">144211490816</journals>
<journals name="INFORMS Journal on Computing">144211671040</journals>
<journals name="Issues in Accounting Education">152044705792</journals>
<journals name="Journal of Accounting and Economics">144211507200</journals>
<journals name="Journal of Accounting Education">152044713984</journals>
<journals name="Journal of Accounting Research">142384451584</journals>
<journals name="Journal of Consumer Research">144211509248</journals>
<journals name="Journal of Finance">144211523584</journals>
<journals name="Journal of Financial Economics">144211531776</journals>
<journals name="Journal of Information Systems">152044726272</journals>
<journals name="Journal of Marketing">142384453632</journals>
<journals name="Journal of Marketing Research">144211544064</journals>
<journals name="Journal of Operations Management">144211556352</journals>
<journals name="Management Accounting Review">152044740608</journals>
<journals name="Management Science">144211566592</journals>
<journals name="Manufacturing & Service Operations Management">144211580928</journals>
<journals name="Marketing Science">144211591168</journals>
<journals name="MIS Quarterly">144211607552</journals>
<journals name="Operations Research">144211615744</journals>
<journals name="Organization Science">144211619840</journals>
<journals name="Production and Operations Management">144211630080</journals>
<journals name="Review of Accounting Studies">152044746752</journals>
<journals name="Review of Financial Studies">144211634176</journals>
<journals name="Strategic Management Journal">144211638272</journals>
<journals name="The Accounting Review">144211658752</journals>
<journals name="Not in List">-1</journals>

	*/


	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	SET @responseText = '<journals name="Academy of Management Journal">142384445440</journals>
		<journals name="Academy of Management Review">144211447808</journals>
		<journals name="Accounting Horizons">152044609536</journals>'

	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t;

	SELECT Record.value('@name','varchar(200)')journal_name,	
		ISNULL(Record.value('.','varchar(200)'),'')journal_id,		
		getdate() as Download_Datetime		
	INTO #_Journals
	FROM @responsexml.nodes('/journals')Records(Record)

	select * from #_Journals
END

GO
