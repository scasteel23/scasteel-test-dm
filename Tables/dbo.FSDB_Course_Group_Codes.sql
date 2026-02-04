CREATE TABLE [dbo].[FSDB_Course_Group_Codes]
(
[Course_Group_ID] [int] NOT NULL,
[Course_Subject_Code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Related_Subunit_ID] [int] NULL,
[Related_Department_ID] [int] NULL,
[Course_Group_Abbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Area_ID] [int] NULL,
[Course_Group_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Group_Identity] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Group_Digit_Position] [int] NULL,
[Active_Indicator] [bit] NOT NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
