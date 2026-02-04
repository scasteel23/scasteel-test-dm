CREATE TABLE [dbo].[FSDB_Websites]
(
[Website_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Website_Prefix_URL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL,
[Active_Indicator] [bit] NOT NULL
) ON [PRIMARY]
GO
