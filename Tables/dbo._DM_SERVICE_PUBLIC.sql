CREATE TABLE [dbo].[_DM_SERVICE_PUBLIC]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [int] NULL,
[TYPE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG_REPORTABLE] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMPENSATED] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NUMHOURS_YEARLY] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLASSIFICATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL,
[PERENNIAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_CURRENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_SERVICE_PUBLIC] ADD CONSTRAINT [PK__DM_SERVICE_PUBLIC] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
