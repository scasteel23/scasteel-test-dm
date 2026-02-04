CREATE TABLE [dbo].[_DM_PRESENT]
(
[id] [bigint] NOT NULL,
[Research_Publication_ID] [int] NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLASSIFICATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEETING_TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE_LOCALE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFEREED] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PUBPROCEED] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_DATE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSRN_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOI] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERENNIAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PRESENT] ADD CONSTRAINT [PK__DM_PRESENT_1] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
