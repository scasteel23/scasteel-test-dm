CREATE TABLE [dbo].[_DM_MEDCONT]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[surveyID] [bigint] NULL,
[termID] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REPORTER] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_ADDRESS] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_DATE] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTD_DATE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_DATE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE_START] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE_END] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_MEDCONT] ADD CONSTRAINT [PK__DM_MEDCONT] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
