CREATE TABLE [dbo].[_DM_DEG_COMMITTEE_ROLE]
(
[id] [bigint] NOT NULL,
[SEQ] [int] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UIN] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_DEG_COMMITTEE_ROLE] ADD CONSTRAINT [PK__DM_DEG_COMMITTEE_ROLE] PRIMARY KEY CLUSTERED ([id], [SEQ]) ON [PRIMARY]
GO
