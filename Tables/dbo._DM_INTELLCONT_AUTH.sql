CREATE TABLE [dbo].[_DM_INTELLCONT_AUTH]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[Research_Publication_ID] [int] NULL,
[FACULTY_NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INSTITUTION] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STUDENT_LEVEL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_INTELLCONT_AUTH] ADD CONSTRAINT [PK__DM_INTELLCONT_AUTH] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
