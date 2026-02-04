SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 10/15/2018: 
-- NS 8/2/2017: need to redo dur to different fields
-- NS 4/4/2017: Worked!

CREATE PROC [dbo].[_Test_Shadow_SCHTEACH]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	-- May need to add ICES1, ICES2, ICES_RESPONDENTS

	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-03-28">
		<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="9938794">
			<dmd:IndexEntry indexKey="COLLEGE" entryKey="Education" text="Education"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="ED: Curriculum and Instruction" text="ED: Curriculum and Instruction"/>
			<SCHTEACH id="111841122304" dmd:lastModified="2015-11-20T09:31:44" 
				dmd:startDate="2015-09-01" dmd:endDate="2015-12-31" dmd:primaryKey="Fall|2015|CI|599|FSA">
			<TYT_TERM>Fall</TYT_TERM>
			<TYY_TERM>2015</TYY_TERM>
			<TERM_START>2015-09-01</TERM_START>
			<TERM_END>2015-12-31</TERM_END>
			<TITLE>Thesis Research</TITLE>
			<COURSEPRE>CI</COURSEPRE>
			<COURSENUM>599</COURSENUM>
			<SECTION>FSA</SECTION>
			<ENROLL>3</ENROLL>
			<CHOURS>.00</CHOURS>
			<LEVEL>Graduate</LEVEL>
			<DELIVERY_MODE>Independent Study</DELIVERY_MODE>
			</SCHTEACH>

			<SCHTEACH id="103769094144" dmd:lastModified="2015-05-15T10:49:10" 
				dmd:startDate="2015-01-15" dmd:endDate="2015-04-30" dmd:primaryKey="Spring|2015|CI|599|FSA">
			<TYT_TERM>Spring</TYT_TERM>
			<TYY_TERM>2015</TYY_TERM>
			<TERM_START>2015-01-15</TERM_START>
			<TERM_END>2015-04-30</TERM_END>
			<TITLE>Thesis Research</TITLE>
			<COURSEPRE>CI</COURSEPRE>
			<COURSENUM>599</COURSENUM>
			<DEGREE_PROGRAM>Bachelor''s</DEGREE_PROGRAM>
			<DEGREE_PROGRAM>Doctoral</DEGREE_PROGRAM>
			<DEGREE_PROGRAM>MBA</DEGREE_PROGRAM>
			<SECTION>FSA</SECTION>
			<ENROLL>2</ENROLL>
			<CHOURS>.00</CHOURS>
			<LEVEL>Graduate</LEVEL>
			<DELIVERY_MODE>Independent Study</DELIVERY_MODE>
			</SCHTEACH>
		</Record>
	</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_SCHTEACH @webservices_requests_id=1,@xml=@responsexml, @userid=NULL,@resync=1

GO
