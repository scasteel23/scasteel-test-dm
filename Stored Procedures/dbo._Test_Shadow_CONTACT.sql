SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/29/2017: Worked!

CREATE PROC [dbo].[_Test_Shadow_CONTACT]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-07-28">		
<Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
<CONTACT id="148288843776" dmd:originalSource="MANAGE_DATA" dmd:lastModified="2017-07-27T17:46:51">
<BUILDING />
<ROOM />
<OPHONE1 />
<OPHONE2 />
<OPHONE3 />
<MAILBOX />
<ADDL_BUILDING />
<ADDL_ROOM />
<ADDL_PHONE1 />
<ADDL_PHONE2 />
<ADDL_PHONE3 />
<ADDRESS_DISPLAY />
<PHONE_DISPLAY />
<OFFICE_HOURS />
<APPT_ONLY />
<CAMPUS_EMAIL />
<ADDL_EMAIL />
<HOMEPAGE_WEB_ADDRESS />
<SOCIAL_MEDIA id="148288843780">
<TYPE />
<TYPE_OTHER />
<WEB_ADDRESS />
<SHOW />
 </SOCIAL_MEDIA>
<OTHER_PHONE id="148288843782">
<TYPE />
<PHONE1 />
<PHONE2 />
<PHONE3 />
<PHONE4 />
<SHOW />
 </OTHER_PHONE>
<NAME />
<RELATION />
<EMERGENCY_PHONE1 />
<EMERGENCY_PHONE2 />
<EMERGENCY_PHONE3 />
<EMERGENCY_PHONE4 />
<EMERGENCY_EMAIL />
 </CONTACT>
 </Record>
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<CONTACT id="148311027712" dmd:originalSource="MANUAL" dmd:lastModified="2017-07-28T15:50:55">
<BUILDING />
<ROOM />
<OPHONE1 />
<OPHONE2 />
<OPHONE3 />
<MAILBOX />
<ADDL_BUILDING>Wohlers Hall</ADDL_BUILDING>
<ADDL_ROOM>460</ADDL_ROOM>
<ADDL_PHONE1>217</ADDL_PHONE1>
<ADDL_PHONE2>417</ADDL_PHONE2>
<ADDL_PHONE3>4338</ADDL_PHONE3>
<ADDRESS_DISPLAY>Official Campus Address</ADDRESS_DISPLAY>
<PHONE_DISPLAY>Additional Campus Phone</PHONE_DISPLAY>
<OFFICE_HOURS>Mondays, Thursdays 3:00 - 5:00 PM</OFFICE_HOURS>
<APPT_ONLY>Yes</APPT_ONLY>
<CAMPUS_EMAIL />
<ADDL_EMAIL>fxhadi@gmail.com</ADDL_EMAIL>
<HOMEPAGE_WEB_ADDRESS>http://facebook.com/nursalim.hadi</HOMEPAGE_WEB_ADDRESS>
<SOCIAL_MEDIA id="148311027713">
<TYPE>Website</TYPE>
<TYPE_OTHER />
<WEB_ADDRESS>https://business.illinois.edu/nhadi</WEB_ADDRESS>
<SHOW>Yes</SHOW>
 </SOCIAL_MEDIA>
<SOCIAL_MEDIA id="148311027716">
<TYPE>LinkedIn</TYPE>
<TYPE_OTHER />
<WEB_ADDRESS>https://linkedin.com/nursalim.hadi</WEB_ADDRESS>
<SHOW>Yes</SHOW>
 </SOCIAL_MEDIA>
<SOCIAL_MEDIA id="148311027717">
<TYPE>Facebook</TYPE>
<TYPE_OTHER />
<WEB_ADDRESS>http://facebook.com/nursalim.hadi</WEB_ADDRESS>
<SHOW>Yes</SHOW>
 </SOCIAL_MEDIA>
<SOCIAL_MEDIA id="148311027718">
<TYPE>Other</TYPE>
<TYPE_OTHER>Research Insight</TYPE_OTHER>
<WEB_ADDRESS>http://researchinsight.com/nursalim.hadi</WEB_ADDRESS>
<SHOW>Yes</SHOW>
 </SOCIAL_MEDIA>
<OTHER_PHONE id="148311027714">
<TYPE>Business</TYPE>
<PHONE1>1</PHONE1>
<PHONE2>217</PHONE2>
<PHONE3>333</PHONE3>
<PHONE4>2227</PHONE4>
<SHOW>Yes</SHOW>
 </OTHER_PHONE>
<OTHER_PHONE id="148311027719">
<TYPE>Mobile</TYPE>
<PHONE1>1</PHONE1>
<PHONE2>217</PHONE2>
<PHONE3>417</PHONE3>
<PHONE4>4338</PHONE4>
<SHOW>Yes</SHOW>
 </OTHER_PHONE>
<NAME>Shinta Hadi</NAME>
<RELATION>Spouse</RELATION>
<EMERGENCY_PHONE1>1</EMERGENCY_PHONE1>
<EMERGENCY_PHONE2>217</EMERGENCY_PHONE2>
<EMERGENCY_PHONE3>417</EMERGENCY_PHONE3>
<EMERGENCY_PHONE4>1881</EMERGENCY_PHONE4>
<EMERGENCY_EMAIL>skhadi@illinois.edu</EMERGENCY_EMAIL>
 </CONTACT>
 </Record>
 </Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_CONTACT @xml=@responsexml, @userid=NULL,@resync=1

GO
