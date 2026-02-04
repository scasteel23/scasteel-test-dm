CREATE TABLE [dbo].[_DM_SCHTEACH]
(
[userid] [bigint] NOT NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYT_TERM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYY_TERM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSEPRE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSENUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECTION] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERY_MODE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LEVEL] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEGREE_PROGRAM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ENROLL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CENSUS_ENROLL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHOURS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMI_HOURS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSE_INFO_URL] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYLLABUS] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSE_URL] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICES_COURSE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICES_INSTRUCTOR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICES_RESPONSES] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_SCHTEACH] ADD CONSTRAINT [PK__DM_COURSES] PRIMARY KEY CLUSTERED ([userid], [id]) ON [PRIMARY]
GO
