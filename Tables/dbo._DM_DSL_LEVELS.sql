CREATE TABLE [dbo].[_DM_DSL_LEVELS]
(
[id] [bigint] NOT NULL,
[seq] [int] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LEVELS] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_DSL_LEVELS] ADD CONSTRAINT [PK__DM_DSL_LEVELS] PRIMARY KEY CLUSTERED ([id], [seq]) ON [PRIMARY]
GO
