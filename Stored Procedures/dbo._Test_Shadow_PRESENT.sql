SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 10/12/2016: Must retest due to updates on shadow_screen_data SP
-- NS 10/5/2016
CREATE PROC [dbo].[_Test_Shadow_PRESENT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(MAX)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-05"><Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891"><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/><PRESENT id="134053957632" dmd:lastModified="2016-09-30T19:45:25" dmd:startDate="2016-08-01" dmd:endDate="2016-08-31"><TITLE>Sovereignty and Democracy</TITLE><STATUS>Accepted</STATUS><REFEREED>Yes</REFEREED><NAME>General Assembly</NAME><CITY>New York</CITY><STATE>Illinois</STATE><COUNTRY>United States of America</COUNTRY><MEETING_TYPE>Research Colloquium</MEETING_TYPE><SCOPE_LOCALE>International</SCOPE_LOCALE><ORG>United Nations</ORG><CONTR_TYPE/><DESC>The sovereignty state of a country cannot be looked down and hence cannot be taken into lightly by other countries</DESC><PRESENT_AUTH id="134053957633"><FACULTY_NAME>1791140</FACULTY_NAME><FNAME>Nursalim</FNAME><MNAME/><LNAME>Hadi</LNAME><ROLE>Author</ROLE></PRESENT_AUTH><PRESENT_AUTH id="134053957635"><FACULTY_NAME>1940561</FACULTY_NAME><FNAME>Jeffrey</FNAME><MNAME>R</MNAME><LNAME>Brown</LNAME><ROLE>Author &amp; Presenter</ROLE></PRESENT_AUTH><PRESENT_AUTH id="134053957636"><FACULTY_NAME/><FNAME>Malory</FNAME><MNAME>M</MNAME><LNAME>Jeanne</LNAME><ROLE>Author</ROLE></PRESENT_AUTH><DOI>23450</DOI><SSRN_ID>1456710</SSRN_ID><INVACC>Invited</INVACC><DTM_DATE>August</DTM_DATE><DTY_DATE>2016</DTY_DATE><DATE_START>2016-08-01</DATE_START><DATE_END>2016-08-31</DATE_END><WEB_PROFILE>Yes</WEB_PROFILE><WEB_PROFILE_ORDER>3</WEB_PROFILE_ORDER><USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR></PRESENT><PRESENT id="134053961728" dmd:lastModified="2016-09-30T03:58:34" dmd:startDate="2015-02-01" dmd:endDate="2015-02-28"><TITLE>Bitcoin and Blockchain</TITLE><STATUS>Presented</STATUS><REFEREED>No</REFEREED><NAME>Digital Money in the New Brave World</NAME><CITY>San Fransisco</CITY><STATE>California</STATE><COUNTRY>United States of America</COUNTRY><MEETING_TYPE>Other</MEETING_TYPE><SCOPE_LOCALE>International</SCOPE_LOCALE><ORG>University of Illinois</ORG><CONTR_TYPE>Contributions to Practice</CONTR_TYPE><DESC>Blockchain is the tech</DESC><PRESENT_AUTH id="134053961729"><FACULTY_NAME>1791140</FACULTY_NAME><FNAME>Nursalim</FNAME><MNAME/><LNAME>Hadi</LNAME><ROLE>Presenter</ROLE></PRESENT_AUTH><PRESENT_AUTH id="134053961731"><FACULTY_NAME>1940566</FACULTY_NAME><FNAME>Marcelo</FNAME><MNAME/><LNAME>Bucheli</LNAME><ROLE>Presenter</ROLE></PRESENT_AUTH><DOI>678</DOI><SSRN_ID>12345</SSRN_ID><INVACC>Invited</INVACC><DTM_DATE>February</DTM_DATE><DTY_DATE>2015</DTY_DATE><DATE_START>2015-02-01</DATE_START><DATE_END>2015-02-28</DATE_END><WEB_PROFILE>Yes</WEB_PROFILE><WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER><USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR></PRESENT></Record></Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_PRESENT @xml=@responsexml, @userid=NULL,@resync=1

GO
