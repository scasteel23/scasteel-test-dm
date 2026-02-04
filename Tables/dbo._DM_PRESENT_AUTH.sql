CREATE TABLE [dbo].[_DM_PRESENT_AUTH]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[sequence] [int] NULL,
[Research_Publication_ID] [int] NULL,
[FACULTY_NAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LNAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MNAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PRESENT_AUTH] ADD CONSTRAINT [PK__DM_PRESENT_AUTH] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
