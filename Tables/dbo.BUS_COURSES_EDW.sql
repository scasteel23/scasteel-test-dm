CREATE TABLE [dbo].[BUS_COURSES_EDW]
(
[Facstaff_ID] [int] NULL,
[EDW_PERS_ID] [int] NULL,
[Network_ID] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_SUBJ_CD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NBR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enroll] [int] NULL,
[SECT_CENSUS_ENRL_NBR] [int] NULL,
[CRS_MAX_CREDIT_HOUR_NBR] [decimal] (10, 3) NULL,
[SECT_RESTRICT_VAR_CREDIT_HOUR] [decimal] (10, 3) NULL,
[CRS_NBR_LEVEL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCHED_TYPE_CD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCHED_TYPE_DESC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
