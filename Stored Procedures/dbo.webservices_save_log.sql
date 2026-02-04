SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 6/21/2016

CREATE PROC [dbo].[webservices_save_log] 
(
		@webservices_requests_id int
		,@Post_Or_Get varchar(10)
        ,@What_Loaded varchar(200)
        ,@LOAD_STATUS_CD varchar(50)
        ,@LOAD_STATUS_DESC varchar(2000)
)
AS

 INSERT INTO dbo.webservices_logs
 (	   webservices_requests_id
	  ,Post_Or_Get
      ,What_Loaded
      ,LOAD_STATUS_CD
      ,LOAD_STATUS_DESC
      ,POST_DATE)
VALUES (@webservices_requests_id
	  ,@Post_Or_Get
      ,@What_Loaded
      ,@LOAD_STATUS_CD
      ,@LOAD_STATUS_DESC
      ,getdate())
  

GO
