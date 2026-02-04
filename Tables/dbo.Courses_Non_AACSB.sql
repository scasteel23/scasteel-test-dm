CREATE TABLE [dbo].[Courses_Non_AACSB]
(
[AACSB_Table] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NBR] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
