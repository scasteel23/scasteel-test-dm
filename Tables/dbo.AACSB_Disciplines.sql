CREATE TABLE [dbo].[AACSB_Disciplines]
(
[Discipline_ID] [int] NOT NULL IDENTITY(1, 1),
[Discipline] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Start_Year] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[End_Year] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
