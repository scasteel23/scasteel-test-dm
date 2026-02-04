CREATE TABLE [dbo].[AACSB_15_2_Step4_Faculty_Course_CH]
(
[Log_ID] [int] NOT NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SECT_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDW_PERS_ID] [decimal] (9, 0) NOT NULL,
[Facstaff_ID] [int] NULL,
[PERS_LNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_FNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qualification] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACAD_PGM_CD] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ACAD_PGM_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deg_Level] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCH_Share] [float] NULL,
[Prog_CH] [decimal] (38, 3) NULL,
[CH_Taught] [float] NULL
) ON [PRIMARY]
GO
