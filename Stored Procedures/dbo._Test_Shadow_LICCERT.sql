SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/9/2016

CREATE PROC [dbo].[_Test_Shadow_LICCERT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<LICCERT id="130281576448" dmd:lastModified="2016-06-27T13:52:29" dmd:startDate="2014-01-01" dmd:endDate="2016-05-31">
			<TITLE>Certified License</TITLE>
			<ORG/>
			<SCOPE/>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>2014</DTY_START>
			<START_START>2014-01-01</START_START>
			<START_END>2014-12-31</START_END>
			<DTM_END>May</DTM_END>
			<DTD_END/>
			<DTY_END>2016</DTY_END>
			<END_START>2016-05-01</END_START>
			<END_END>2016-05-31</END_END>
		</LICCERT>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<LICCERT id="130926800896" dmd:lastModified="2016-07-19T09:06:23" dmd:startDate="1995-01-01" dmd:endDate="1996-12-31">
			<TITLE>Microsoft Certificate</TITLE>
			<ORG>Microsoft</ORG>
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>1995</DTY_START>
			<START_START>1995-01-01</START_START>
			<START_END>1995-12-31</START_END>
			<DTM_END/>
			<DTD_END/>
			<DTY_END>1996</DTY_END>
			<END_START>1996-01-01</END_START>
			<END_END>1996-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</LICCERT>
		<LICCERT id="130926809088" dmd:lastModified="2016-07-19T09:07:04" dmd:startDate="1984-01-01" dmd:endDate="1986-12-31">
			<TITLE>IBM JCL</TITLE>
			<ORG>IBM</ORG>
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>1984</DTY_START>
			<START_START>1984-01-01</START_START>
			<START_END>1984-12-31</START_END>
			<DTM_END/>
			<DTD_END/>
			<DTY_END>1986</DTY_END>
			<END_START>1986-01-01</END_START>
			<END_END>1986-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</LICCERT>
	</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_LICCERT @xml=@responsexml, @userid=NULL,@resync=1

GO
