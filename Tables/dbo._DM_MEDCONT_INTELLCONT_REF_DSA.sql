CREATE TABLE [dbo].[_DM_MEDCONT_INTELLCONT_REF_DSA]
(
[id] [bigint] NOT NULL,
[itemid] [bigint] NOT NULL,
[sequence] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_MEDCONT_INTELLCONT_REF_DSA] ADD CONSTRAINT [PK__DM_MEDCONT_INTELLCONT_REF_DSA] PRIMARY KEY CLUSTERED ([id], [itemid]) ON [PRIMARY]
GO
