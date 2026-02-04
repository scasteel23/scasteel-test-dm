CREATE TABLE [dbo].[_DM_CURRICULUM]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EVENT] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRES_TITLE] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_CURRICULUM] ADD CONSTRAINT [PK__DM_INNOVATION] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
