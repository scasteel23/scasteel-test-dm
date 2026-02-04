SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/19/2017 : worked

CREATE PROC [dbo].[_Test_Shadow_PROFILE]
AS

	DECLARE @responseXML as XML
	DECLARE @responseText as varchar(8000)
	DECLARE @t table (ID int, strxml xml)


	SET @responseText = 
	'<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-09-19">
		<Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
		<PROFILE id="146245117952" dmd:originalSource="IMPORT" dmd:lastModified="2017-07-27T16:22:05">
			<BIO><p><font face="Tahoma"><b>A. Rashad Abdel-khalik</b> is a professor of accountancy and the Director of the V. K Zimmerman Center for International Education and Research in Accounting at the University of Illinois at Urbana-Champaign. He earned his undergraduate degree in commerce from Cairo University, an M.B.A. (Accounting) and an M.A. (Economics) from Indiana University-Bloomington, and a Ph.D. (Accountancy) from the University of Illinois at Urbana-Champaign. He taught at Illinois, Columbia University, Duke University, and the University of Florida before returning to the University of Illinois.</font></p><p><font face="Tahoma">Professor Abdel-khalik has published articles in <em>The Accounting Review</em>, <em>Journal of Accounting Research</em>, <em>Contemporary Research in Accounting</em>, <em>Decision Sciences</em>, <em>Organization Studies</em> and the <em>European Accounting Review</em> and has authored and co-authored research studies published by the American Accounting Association and the Financial Accounting Standards Board. He is currently the Editor of the <em>International Journal of Accounting</em> and has served as the founding editor of <em>Journal of Accounting Literature</em> and editor of <em>The Accounting Review</em>, the quarterly research journal of the American Accounting Association. His research interests are in the areas of financial accounting and reporting.</font></p></BIO>
			<SPECIALIZATION />
			<PROF_INTERESTS />
			<RESEARCH_INTERESTS>Accounting Reporting Risk, Empirical Research in Accounting, Research Methodology, Accounting Theory, and Current Issues in Financial Reporting.</RESEARCH_INTERESTS>
			<TEACHING_INTERESTS>Currently: Accounting for Risk and Hedge Accounting; Empirical Research in Accounting Previously: Taught courses on the following subjects: Principles of Accounting, Principles of Economics, Intermediate Microeconomics; Intermiediate Macroeconomics, Introductory Statistics (a two-course sequence), Money and Banking, Intermediate Accounting, Accounting Theory, Management Control Systems, Financial Research in Accounting, Managerial Research in Accounting, Issues and Cases in Accounting, Controllership, and Advanced Accounting Analysis; and Analysis of Financial Statements</TEACHING_INTERESTS>
			<OTHER_INTERESTS />
			<LANGUAGES id="146245117953">
				<FLUENCY>Native or Bilingual</FLUENCY>
				<LANGUAGE>Arabic</LANGUAGE>
				<LANGUAGE_OTHER />
			</LANGUAGES>
			<LANGUAGES id="146245117955">
				<FLUENCY>Full Professional</FLUENCY>
				<LANGUAGE>English</LANGUAGE>
				<LANGUAGE_OTHER />
				</LANGUAGES>
			<LANGUAGES id="146245117956">
				<FLUENCY>Limited Working</FLUENCY>
				<LANGUAGE>French</LANGUAGE>
				<LANGUAGE_OTHER />
			</LANGUAGES>
		</PROFILE>
		</Record>
		</Data>'

	--print @responseText
	Insert into @t (strxml)
	values(@responseText)

	select @responsexml =  strxml from @t
	EXEC dbo.shadow_PROFILE @xml=@responsexml, @userid=NULL,@resync=1

GO
