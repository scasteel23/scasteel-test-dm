CREATE TABLE [dbo].[_DM_PASTHIST]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [int] NULL,
[EXPTYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG_REPORTABLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWN_COMPANY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLASSIFICATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMPENSATED] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NUMHOURS_YEARLY] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL,
[FSDB_CURRENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PASTHIST] ADD CONSTRAINT [PK__DM_PASYHIST] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
