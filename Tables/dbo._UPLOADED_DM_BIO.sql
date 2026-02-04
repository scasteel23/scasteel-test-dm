CREATE TABLE [dbo].[_UPLOADED_DM_BIO]
(
[userid] [bigint] NULL,
[ID] [bigint] NULL,
[surveyID] [bigint] NULL,
[termID] [bigint] NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BIO_SKETCH] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROF_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEACHING_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESEARCH_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_datetime] [datetime] NULL,
[lastModified] [datetime] NULL
) ON [PRIMARY]
GO
