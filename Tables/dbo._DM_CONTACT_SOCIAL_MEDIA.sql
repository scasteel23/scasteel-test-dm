CREATE TABLE [dbo].[_DM_CONTACT_SOCIAL_MEDIA]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [bigint] NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE_OTHER] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_ADDRESS] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHOW] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_CONTACT_SOCIAL_MEDIA] ADD CONSTRAINT [PK__DM_CONTACT_SOCMED] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
