CREATE TABLE [dbo].[_DM_PROFILE]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[surveyID] [bigint] NULL,
[termID] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BIO] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROF_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OTHER_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEACHING_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESEARCH_INTERESTS] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPECIALIZATION] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PROFILE] ADD CONSTRAINT [PK__DM_BIO] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
