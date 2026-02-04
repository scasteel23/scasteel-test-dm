CREATE TABLE [dbo].[AACSB_2_1_Grants]
(
[Log_ID] [int] NOT NULL,
[Facstaff_ID] [int] NOT NULL,
[AACSB_Department] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Author_Share] [float] NULL,
[Author_Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Classified] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AACSB_Class] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Start Year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[End Year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Grant Title] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Grant Agency] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Investigators] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Research_Grant_ID] [int] NOT NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL,
[Last_Update_Network_ID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
