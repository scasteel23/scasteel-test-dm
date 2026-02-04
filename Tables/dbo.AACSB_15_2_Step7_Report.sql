CREATE TABLE [dbo].[AACSB_15_2_Step7_Report]
(
[Log_ID] [int] NOT NULL,
[ACAD_PGM_CD] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ACAD_PGM_NAME] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Deg_Level] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Display_Order] [int] NOT NULL,
[SA] [decimal] (4, 3) NULL,
[PA] [decimal] (4, 3) NULL,
[SP] [decimal] (4, 3) NULL,
[IP] [decimal] (4, 3) NULL,
[Other] [decimal] (4, 3) NULL,
[Total] [decimal] (8, 3) NULL
) ON [PRIMARY]
GO
