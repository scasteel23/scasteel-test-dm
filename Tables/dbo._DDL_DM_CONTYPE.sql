CREATE TABLE [dbo].[_DDL_DM_CONTYPE]
(
[Research_Publication_Type] [int] NOT NULL,
[Research_Publication_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL,
[Research_Publication_Short_Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
