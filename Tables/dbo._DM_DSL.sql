CREATE TABLE [dbo].[_DM_DSL]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROGRAM] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPONSOR] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INSTITUTION] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPONSOR_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[START_START] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[START_END] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[END_START] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[END_END] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_DSL] ADD CONSTRAINT [PK__DM_DSL] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
