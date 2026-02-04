CREATE TABLE [dbo].[Courses_BUS_New]
(
[Facstaff_ID] [int] NULL,
[EDW_PERS_ID] [decimal] (9, 0) NOT NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TERM_DESC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_TITLE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_DESC_TXT] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SECT_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCHED_TYPE_CD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCHED_TYPE_DESC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_FNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_MNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_LNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_NAME_SUFFIX] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERS_PREFERRED_FNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
