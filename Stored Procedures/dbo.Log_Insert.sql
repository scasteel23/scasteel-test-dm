SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/

-- NS 8/28/2017
CREATE PROC [dbo].[Log_Insert]
(
	@Screen_Name varchar(60)
    ,@Activity varchar(200)
	,@Tag varchar(30)
    ,@Create_Network_ID varchar(60)
)
AS 
	INSERT INTO dbo.webservices_activity_logs(
       Screen_Name
      ,Activity
	  ,Tag
      ,Create_Network_ID
      ,Create_Datetime)

	VALUES (@Screen_Name
      ,@Activity
	  ,@Tag
      ,@Create_Network_ID
	  ,getdate())

/*
	DECLARE @Screen_Name varchar(60)
    ,@Activity varchar(200)
	,@Tag varchar(30)
    ,@Create_Network_ID varchar(60)

	SET @Screen_Name='USERS'
    SET @Activity='downloading'
	SET @Tag='start'
    SET @Create_Network_ID='test-id'

	EXEC dbo.Log_Insert @Screen_Name=@Screen_Name
      ,@Activity=@Activity
	  ,@Tag=@Tag
      ,@Create_Network_ID=@Create_Network_ID
*/
GO
