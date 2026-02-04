CREATE TABLE [dbo].[Employee_Contact_Info_Staging]
(
[EDW_PERS_ID] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UIN] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Net ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Last_Name] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[First_Name] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sub_Types] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Type] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_Last] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_First] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact_Middle] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Relationship] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address_Code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Until_Date] [datetime2] NULL,
[Phone_Code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Area_Code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone_Number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone_Ext] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Intl_Access] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Current_Indicator] [bit] NOT NULL,
[Last_Updated] [datetime2] NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[Set_Employee_Contact_Info_Staging_Create_Datetime] 
   ON [dbo].[Employee_Contact_Info_Staging]
AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @contact_type VARCHAR(50) 

	SELECT @contact_type = Contact_Type
	FROM inserted 
	
	UPDATE [dbo].[Employee_Contact_Info_Staging]
	SET Create_Datetime = CURRENT_TIMESTAMP
	WHERE Contact_Type = @contact_type

	RETURN    -- Insert statements for trigger here

END
GO
DISABLE TRIGGER [dbo].[Set_Employee_Contact_Info_Staging_Create_Datetime] ON [dbo].[Employee_Contact_Info_Staging]
GO
