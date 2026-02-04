SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 5/31/2017

CREATE PROC [dbo].[_Test_Shadow_USERS]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)

	-- https://www.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business
	/*
<User username="sonali" UIN="650512159" FacstaffID="129" EDWPERSID="443033"><LastName>Shah</LastName><MiddleName>K. </MiddleName><FirstName>Sonali</FirstName><Email>sonali@illinois.edu</Email></User>
<User username="peecher" UIN="652405652" FacstaffID="40" EDWPERSID="43182"><LastName>Peecher</LastName><MiddleName>E</MiddleName><FirstName>Mark</FirstName><Email>peecher@illinois.edu</Email></User>
<User username="nstewart" UIN="657696571" FacstaffID="17047" EDWPERSID="28149"><LastName>Stewart</LastName><MiddleName>Leigh</MiddleName><FirstName>Nicole</FirstName><Email>nstewart@illinois.edu</Email></User>
<User username="mdonohoe" UIN="669516945" FacstaffID="13703" EDWPERSID="2601802"><LastName>Donohoe</LastName><MiddleName>P</MiddleName><FirstName>Michael</FirstName><Email>mdonohoe@illinois.edu</Email></User>
<User username="kstarks" UIN="656396994" FacstaffID="11937" EDWPERSID="33359"><LastName>Starks</LastName><MiddleName>M</MiddleName><FirstName>Karen</FirstName><Email>kstarks@illinois.edu</Email></User>
<User username="kfoong2" UIN="658841062" FacstaffID="101564" EDWPERSID="3817408"><LastName>Foong</LastName><MiddleName>Kar-Lei</MiddleName><FirstName>Katherine</FirstName><Email>kfoong2@illinois.edu</Email></User>
<User username="heid" UIN="653499557" FacstaffID="15923" EDWPERSID="10629"><LastName>Heid</LastName><MiddleName>L</MiddleName><FirstName>Rebecca</FirstName><Email>heid@illinois.edu</Email></User>
<User username="cvonholt" UIN="677093534" FacstaffID="16336" EDWPERSID="4092875"><LastName>Von Holten</LastName><MiddleName>J</MiddleName><FirstName>Courtney</FirstName><Email>cvonholt@illinois.edu</Email></User>
<User username="ambauer" UIN="665168673" FacstaffID="13853" EDWPERSID="3507263"><LastName>Bauer</LastName><MiddleName>M.</MiddleName><FirstName>Andrew</FirstName><Email>ambauer@illinois.edu</Email></User>
	*/
	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-06">'+
	'<Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311"><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/><PCI id="130713020416" dmd:lastModified="2016-07-11T11:37:44"><FNAME>Ahmed</FNAME><MNAME>Rashad</MNAME><LNAME>Abdel-Khalik</LNAME><EMAIL>rashad@illinois.edu</EMAIL></PCI></Record>'+
	'<Record userId="1940574" username="halmeida" termId="6117" dmd:surveyId="17825316"><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/><PCI id="130713239552" dmd:lastModified="2016-07-11T11:48:38"><FNAME>Heitor</FNAME><MNAME/><LNAME>Almeida</LNAME><EMAIL>halmeida@illinois.edu</EMAIL></PCI></Record>'+
	'<Record userId="1940561" username="brownjr" termId="6117" dmd:surveyId="17825302"><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Office of the Dean" text="Office of the Dean"/><PCI id="130712037376" dmd:lastModified="2016-07-11T11:05:16"><FNAME>Jeffrey</FNAME><MNAME>R</MNAME><LNAME>Brown</LNAME><EMAIL>brownjr@illinois.edu</EMAIL></PCI></Record>'+
	'<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890"><PCI id="125211813888" dmd:lastModified="2016-08-23T10:22:21"><FNAME>Scott</FNAME><MNAME/><LNAME>Casteel</LNAME><PFNAME/><EMAIL>scasteel@illinois.edu</EMAIL><DTM_DOB/><DTD_DOB/><DTY_DOB/><DOB_START/><DOB_END/><GENDER/><ETHNICITY/><CITIZEN/><PROF_INTERESTS/><TEACHING_INTERESTS/><RESEARCH_INTERESTS/><UPLOAD_CV>scasteel/pci/Vader Resume-1.docx</UPLOAD_CV><SHOW_CV/><SHOW_PHOTO/></PCI></Record>'+
	'<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891"><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/><dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/><PCI id="125213026304" dmd:lastModified="2016-08-23T10:22:21"><FNAME>FX</FNAME><MNAME>Nusalim</MNAME><LNAME>Hadi</LNAME><PFNAME>Nursalim</PFNAME><EMAIL>nhadi@illinois.edu</EMAIL><DTM_DOB>January</DTM_DOB><DTD_DOB>1</DTD_DOB><DTY_DOB>1965</DTY_DOB><DOB_START>1965-01-01</DOB_START><DOB_END>1965-01-01</DOB_END><GENDER/><ETHNICITY/><CITIZEN/><PROF_INTERESTS>this my brief professional summary</PROF_INTERESTS><TEACHING_INTERESTS>my teaching summary</TEACHING_INTERESTS><RESEARCH_INTERESTS>my research specialty executive summary</RESEARCH_INTERESTS><UPLOAD_CV/><SHOW_CV>No</SHOW_CV><SHOW_PHOTO>No</SHOW_PHOTO></PCI></Record>'+
	'</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_PCI @xml=@responsexml, @userid=NULL,@resync=1

GO
