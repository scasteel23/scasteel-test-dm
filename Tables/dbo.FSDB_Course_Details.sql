CREATE TABLE [dbo].[FSDB_Course_Details]
(
[Course_ID] [int] NOT NULL,
[Facstaff_ID] [int] NOT NULL,
[CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRS_TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NBR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCHED_TYPE_CD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enrollment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Web_URL] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Syllabus_Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_Syllabus_Extension] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_Course_Details] ADD CONSTRAINT [PK_FSDB_Course_Details] PRIMARY KEY CLUSTERED ([Course_ID], [Facstaff_ID], [CRS_ID], [TERM_CD], [CRN], [CRS_SUBJ_CD], [CRS_NBR]) ON [PRIMARY]
GO
