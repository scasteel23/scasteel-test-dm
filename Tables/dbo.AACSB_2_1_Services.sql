CREATE TABLE [dbo].[AACSB_2_1_Services]
(
[Log_ID] [int] NULL,
[Facstaff_ID] [int] NOT NULL,
[AACSB_Department] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Author_Share] [float] NULL,
[Author_Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Classified] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AACSB_Class] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Service Type] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sub Type] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gies_IC_Type] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Start Year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[End Year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Organization] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scope] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Service_Activity_ID] [int] NOT NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL,
[Last_Update_Network_ID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
