CREATE TABLE [dbo].[Course_Linked_Section_Weights]
(
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCHED_TYPE_CD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCHED_TYPE_DESC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Section_Weight] [float] NOT NULL
) ON [PRIMARY]
GO
