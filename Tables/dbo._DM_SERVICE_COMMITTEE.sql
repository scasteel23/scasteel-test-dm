CREATE TABLE [dbo].[_DM_SERVICE_COMMITTEE]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [int] NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_CURRENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_SERVICE_COMMITTEE] ADD CONSTRAINT [PK__DM_SERVICE_UNIVERSITY] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
