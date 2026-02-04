SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/

-- NS 9/7/2016
CREATE PROC [dbo].[_Test_09072016]
AS

 /* 
	MAIN STEPS TO DO DM DOWNLOAD TESTING

	0. All happened in DM_Shadow_Staging database first

	1. Create a request record in webservices_requests table by running any one of the following examples
			EXEC dbo.webservices_initiate @screen='USERS'
			EXEC dbo.webservices_initiate @screen='PCI'
			EXEC dbo.webservices_initiate @screen='AWARDHONOR'

			a "GET" (method column) record will be created for each run

		OR manually reset a request record in webservices_requests table, for example

			UPDATE dbo.webservices_requests
			SET  completed=NULL,processed=NULL,responsecode=null
				  ,response=null,process=null,initiated=null
			WHERE [id]=91

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
  /*

 -- reset all PCI (2), USERS (1), AWARDHONOR (93) requests , so that they can be called again by DTSX
 update [DM_Shadow_Staging].[dbo].[webservices_requests]
 set  [responseCode] = NULL
      ,[response] = NULL
      ,[process] = NULL
      ,[initiated] = NULL
      ,[completed] = NULL
      ,[processed] = NULL
 where id>=96

  
*/

GO
