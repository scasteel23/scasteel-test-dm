CREATE TABLE [dbo].[_DM_PROFILE_LANGUAGES]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLUENCY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LANGUAGE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LANGUAGE_OTHER] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PROFILE_LANGUAGES] ADD CONSTRAINT [PK__DM_PROFILE_LANGUAGES] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
