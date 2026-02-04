CREATE TABLE [dbo].[FSDB_Subunit_Codes]
(
[Subunit_ID] [int] NOT NULL,
[Department_ID] [int] NULL,
[Subunit_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DM_Area_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Web_Area_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Web_Directory_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Web_Directory_Short_Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Web_Active_Indicator] [bit] NULL,
[Subunit_Short_Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subunit_Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
