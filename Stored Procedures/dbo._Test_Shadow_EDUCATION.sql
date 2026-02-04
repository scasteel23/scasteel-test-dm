SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/9/2016
CREATE PROC [dbo].[_Test_Shadow_EDUCATION]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	 <Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<EDUCATION id="126368507904" dmd:lastModified="2016-06-21T14:04:34" dmd:startDate="2005-01-01" dmd:endDate="2005-12-31">
			<LEVEL>Bachelors</LEVEL>
			<NAME>BS</NAME>
			<SCHOOL>Coolige</SCHOOL>
			<LOCATION/>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST/>
			<YR_COMP>2005</YR_COMP>
			<COMP_START>2005-01-01</COMP_START>
			<COMP_END>2005-12-31</COMP_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
		<EDUCATION id="128304977920" dmd:lastModified="2016-05-05T15:02:34" dmd:startDate="1997-01-01" dmd:endDate="1997-12-31">
			<LEVEL>Bachelors</LEVEL>
			<NAME>BS in Computer Science</NAME>
			<SCHOOL>University of Illinois</SCHOOL>
			<LOCATION>Urbana-Champaign</LOCATION>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST>No</HIGHEST>
			<YR_COMP>1997</YR_COMP>
			<COMP_START>1997-01-01</COMP_START>
			<COMP_END>1997-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
		<EDUCATION id="130107848704" dmd:lastModified="2016-06-20T10:16:53" dmd:startDate="1910-01-01" dmd:endDate="1910-12-31">
			<LEVEL>Others</LEVEL>
			<NAME>Celcius</NAME>
			<SCHOOL>Weather Institute</SCHOOL>
			<LOCATION/>
			<MAJOR/>
			<FIELDS/>
			<SUPPAREA/>
			<DISSTITLE/>
			<DISSAREA/>
			<DISSADVISOR/>
			<DISTINCTION/>
			<HIGHEST/>
			<YR_COMP>1910</YR_COMP>
			<COMP_START>1910-01-01</COMP_START>
			<COMP_END>1910-12-31</COMP_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</EDUCATION>
	</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_EDUCATION @xml=@responsexml, @userid=NULL,@resync=1

GO
