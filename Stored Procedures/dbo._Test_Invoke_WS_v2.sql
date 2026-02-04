SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- NS 9/7/2016 it worked for GET method, see _Test_Shadow SP
-- Provide a WS URL of an entity (MEMBER, AWARDHONOR, EDUCATION, ...) and get an XML stream

-- NS 6/3/2016: original

-- =============================================
-- Author:    Brad Old - Bold Tech Solutions Ltd - www.bold.co.nz
-- Create date: 01/08/2013
-- Description:  www.vishalseth.com/.../...dure%29-using-MSXML.aspx
-- http://www.vishalseth.com/post/2009/12/22/Call-a-webservice-from-TSQL-%28Stored-Procedure%29-using-MSXML.aspx
-- =============================================

CREATE PROC [dbo].[_Test_Invoke_WS_v2]
(
      @URI varchar(2000) = '',      
      @methodName varchar(50) = '',
      @requestBody varchar(8000) = '',
      --@SoapAction varchar(255),
      @UserName nvarchar(100), -- Domain\UserName or UserName
      @Password nvarchar(100),
      @responsexml xml output
	  )

AS

SET NOCOUNT ON
declare @responseText varchar(8000)
IF    @methodName = ''
BEGIN
      select FailPoint = 'Method Name must be set'
      return
END

SET @responseText = 'FAILED'

DECLARE @objectID int
DECLARE @hResult int
DECLARE @source varchar(255), @desc varchar(255)
DECLARE @t table (ID int, strxml xml)


EXEC @hResult = sp_OACreate 'MSXML2.ServerXMLHTTP', @objectID OUT
IF @hResult <> 0
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult),
                  source = @source,
                  description = @desc,
                  FailPoint = 'Create failed',
                  MedthodName = @methodName
      goto destroy
      return
END
-- open the destination URI with Specified method
EXEC @hResult = sp_OAMethod @objectID, 'open', null, @methodName, @URI, 'false', @UserName, @Password
IF @hResult <> 0
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult),
            source = @source,
            description = @desc,
            FailPoint = 'Open failed',
            MedthodName = @methodName
      goto destroy
      return
END
-- send the request
EXEC @hResult = sp_OAMethod @objectID, 'send', null, @requestBody
IF    @hResult <> 0
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult),
            source = @source,
            description = @desc,
            FailPoint = 'Send failed',
            MedthodName = @methodName
      goto destroy
      return
END
declare @statusText varchar(1000), @status varchar(1000)
-- Get status text
exec sp_OAGetProperty @objectID, 'StatusText', @statusText out
exec sp_OAGetProperty @objectID, 'Status', @status out
select @status, @statusText, @methodName
-- Get response text
--print 'Get response text'
--Insert into @t (strxml)
--     exec sp_OAGetProperty @objectID, 'responseText', @responseText out

exec sp_OAGetProperty @objectID, 'responseText', @responseText out

IF @hResult <> 0
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult),
            source = @source,
            description = @desc,
            FailPoint = 'ResponseText failed',
            MedthodName = @methodName
      goto destroy
      return
END
Insert into @t (strxml)
values(@responseText)

select @responsexml =  strxml from @t
destroy:	 
      exec sp_OADestroy @objectID
SET NOCOUNT OFF



GO
