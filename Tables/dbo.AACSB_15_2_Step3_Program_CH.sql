CREATE TABLE [dbo].[AACSB_15_2_Step3_Program_CH]
(
[Log_ID] [int] NOT NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SECT_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ACAD_PGM_CD] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ACAD_PGM_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deg_Level] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prog_CH] [decimal] (38, 3) NULL
) ON [PRIMARY]
GO
