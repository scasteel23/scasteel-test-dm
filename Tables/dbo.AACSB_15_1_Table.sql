CREATE TABLE [dbo].[AACSB_15_1_Table]
(
[Row_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Discipline] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sort] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facstaff_ID] [int] NULL,
[Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First_Appt_Date] [datetime] NULL,
[Degree] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Teaching_P] [float] NULL,
[Teaching_S] [float] NULL,
[Responsibilities] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Percent_SA] [float] NULL,
[Percent_PA] [float] NULL,
[Percent_SP] [float] NULL,
[Percent_IP] [float] NULL,
[Percent_Other] [float] NULL,
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Percent_Time] [decimal] (4, 2) NULL,
[Date_Invalid] [bit] NULL
) ON [PRIMARY]
GO
