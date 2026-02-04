CREATE TABLE [dbo].[AACSB_15_2_Step6_Qual_Program_CH]
(
[Log_ID] [int] NOT NULL,
[ACAD_PGM_CD] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ACAD_PGM_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deg_Level] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qualification] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CH_Taught] [float] NULL
) ON [PRIMARY]
GO
