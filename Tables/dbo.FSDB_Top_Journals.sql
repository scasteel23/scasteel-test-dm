CREATE TABLE [dbo].[FSDB_Top_Journals]
(
[Journal_Group_ID] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Journal_ID] [int] NOT NULL,
[Journal_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
