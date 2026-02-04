CREATE TABLE [dbo].[JOURNAL]
(
[USERNAME] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [bigint] NULL,
[JOURNAL_NAME] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REFEREED] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REVIEW_TYPE] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCEPT_RATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTDALLAS] [bit] NULL,
[Journal_ID] [int] NULL
) ON [PRIMARY]
GO
