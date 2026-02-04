CREATE TABLE [dbo].[_DM_AWARDHONOR]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG_REPORTABLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE_LOCALE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERENNIAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Profile_Reference_ID] [bigint] NULL,
[Profile_Year_String] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_AWARDHONOR] ADD CONSTRAINT [PK__DM_AWARDHONOR] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
