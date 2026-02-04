CREATE TABLE [dbo].[_DM_ADMIN_DEP]
(
[id] [bigint] NOT NULL,
[userid] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AC_YEAR] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHOW_DIRECTORY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQ] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_ADMIN_DEP] ADD CONSTRAINT [PK__DM_ADMIN_DEP] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
