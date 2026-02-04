SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/5/2018
-- NS 9/7/2016

CREATE PROC [dbo].[_Test_Shadow_AWARDHONOR]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	 <Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
		<AWARDHONOR id="144075419648" dmd:lastModified="2018-07-05T10:24:25" dmd:startDate="1984-08-01" dmd:endDate="2020-01-31">
			<NAME>N/A</NAME>
			<ORG>Beta Alpha Psi, Alpha Chapter (The professional fraternity of accounting)</ORG>
			<ORG_REPORTABLE>Beta Alpha Psi, Alpha Chapter (The professional fraternity of accounting)</ORG_REPORTABLE>
			<SCOPE>Academic Service</SCOPE>
			<SCOPE_LOCALE>National</SCOPE_LOCALE>
			<DTM_START>August</DTM_START>
			<DTY_START>1984</DTY_START>
			<START_START>1984-08-01</START_START>
			<START_END>1984-08-31</START_END>
			<DTM_END>January</DTM_END>
			<DTY_END>2020</DTY_END>
			<END_START>2020-01-01</END_START>
			<END_END>2020-01-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>No</PERENNIAL>
		 </AWARDHONOR>		
	</Record>
	</Data>'

	
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_AWARDHONOR @webservices_requests_id=1, @xml=@responsexml, @userid=NULL,@resync=1

GO
