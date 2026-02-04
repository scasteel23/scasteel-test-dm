SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/

-- NS 8/30/2016 : retested
-- NS 6/27/2016 : first testing 
-- Recreate all 9 test users
CREATE PROC [dbo].[_Test_06272016]
AS

 /* 
	MAIN STEPS TO DO DM DOWNLOAD TESTING

	0. All happened in DM_Shadow_Staging database first

	1. Create a request record in webservices_requests table by running any one of the following examples
			EXEC dbo.webservices_initiate @screen='USERS'
			EXEC dbo.webservices_initiate @screen='PCI'
			EXEC dbo.webservices_initiate @screen='EDUCATION'

			a "GET" (method column) record will be created for each run

		OR manually reset a request record in webservices_requests table, for example

			UPDATE dbo.webservices_requests
			SET  completed=NULL,processed=NULL,responsecode=null
				  ,response=null,process=null,initiated=null
			WHERE id in (343,336,330,322,316)

	2. RUN Visual Studio to open DMFeed.sln, and RUN FSDB_Get_Users_OneTimeRequest.dtsx from there

	
	This is how to test individual shadow_* stored procedure

	DECLARE @id INT
	DECLARE @response as nvarchar(MAX)
	SET @id=91
	SELECT @response = response FROM dbo.webservices_requests WHERE id=@id 

	IF (SELECT method FROM dbo.webservices_requests WHERE id=@id) = 'GET' BEGIN
			DECLARE @url VARCHAR(255) = (SELECT url FROM dbo.webservices_requests WHERE id=@id);
			DECLARE @initiated VARCHAR(255) = (SELECT initiated FROM dbo.webservices_requests WHERE id=@id);
			DECLARE @urlDetail VARCHAR(50) = SUBSTRING(@url,CHARINDEX('/SchemaData/INDIVIDUAL-ACTIVITIES-Business/',@url)+43,999) 
			IF @urlDetail LIKE 'COLLEGE:Business/%' SET @urlDetail = SUBSTRING(@urlDetail,19,999);
			IF @urlDetail LIKE 'USERNAME:%' EXEC dbo.shadow_user @response,@initiated										-- get particular user data
			ELSE IF @urlDetail='AWARDHONOR' EXEC dbo.shadow_AWARDHONOR @response,@resync=1									-- get all AWARDHONOR screen data
			ELSE IF @urlDetail='EDUCATION' EXEC dbo.shadow_EDUCATION @response,@resync=1									-- get all EDUCATION screen data
			ELSE IF @urlDetail='MEMBER' EXEC dbo.shadow_MEMBER @response,@resync=1											-- get all MEMBER screen data
			ELSE IF @urlDetail='PCI' EXEC dbo.shadow_PCI @response,@resync=0												-- get all PCI screen data
			ELSE IF @url='/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business' EXEC dbo.shadow_USERS @response,@resync=1	-- get all users
			ELSE RAISERROR('No shadow_* Stored Procedure for this web service data',18,1);
	END

	
	 
	

 */
   SELECT TOP 1000 [id]
      ,[method]
      ,[url]
      ,[post]
      ,[responseCode]
      ,[response]
      ,[created]
      ,[process]
      ,[initiated]
      ,[completed]
      ,[processed]
      ,[dependsOn]
  FROM [DM_Shadow_Staging].[dbo].[webservices_requests]

  /*
  
	-- RESET requests by ID
    update [DM_Shadow_Staging].[dbo].[webservices_requests]
	set  [responseCode] = NULL
		  ,[response] = NULL
		  ,[process] = NULL
		  ,[initiated] = NULL
		  ,[completed] = NULL
		  ,[processed] = NULL
		  ,dependsOn = null
	where id = 1733
	---------------------------------------------------------------------

  -- reset all PCI requests, so that they can be called again by DTSX
  update [DM_Shadow_Staging].[dbo].[webservices_requests]
  set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL
	  ,dependsOn = null
 where id in (18,22,26,30,34,38,42,46,50)

 -- reset to GET PCI
  update [DM_Shadow_Staging].[dbo].[webservices_requests]
  set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL
	  ,dependsOn = null
 where id in (16)

 -- >>>>>>>>>>>>>>>>>>>>>>>>> NS 6/27/2016
 -- reset all user creations
 update [DM_Shadow_Staging].[dbo].[webservices_requests]
 set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL
 where id in (17,19, 21,23, 25,27, 29,31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51)

 -- reset all /login/service/v4/UserSchema/USERNAME:[username] this is to create PCI and other screen records
 update [DM_Shadow_Staging].[dbo].[webservices_requests]
  set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL	 
	  ,post='<INDIVIDUAL-ACTIVITIES-Business><ADMIN_DEP><DEP>ED:  College of Education CIO</DEP></ADMIN_DEP></ADMIN></INDIVIDUAL-ACTIVITIES-Business>'
 where id in (20,24,28,32,36,40,44,48,52)

 -- reset all PCI requests, so that they can be called again by DTSX
 update [DM_Shadow_Staging].[dbo].[webservices_requests]
 set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL
 where id=91
 where id in (82,83,84,85,86,87,88,89,90)

 where id=89
 update [DM_Shadow_Staging].[dbo].[webservices_requests]
 set dependsOn = 52
 where id=90


 -- dependsOn must be set to 20,24,28,32,36,40,44,48,52 resp for each record above

 update [dbo].[webservices_requests]
 set post = REPLACE(post,'<COLLEGE>Education</COLLEGE>ED: (external) Human &amp; Community Development','<DEP>Human &amp; Community Development</DEP>')

  
*/

GO
