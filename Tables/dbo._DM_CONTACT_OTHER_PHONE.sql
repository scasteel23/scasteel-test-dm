CREATE TABLE [dbo].[_DM_CONTACT_OTHER_PHONE]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [bigint] NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHOW] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_CONTACT_OTHER_PHONE] ADD CONSTRAINT [PK__DM_CONTACT_PROF_PHONE] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
