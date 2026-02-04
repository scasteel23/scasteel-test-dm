CREATE TABLE [dbo].[_DM_SCHTEACH_DEGREE_PROGRAM]
(
[id] [bigint] NOT NULL,
[SEQ] [int] NOT NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSEPRE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COURSENUM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEGREE_PROGRAM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_SCHTEACH_DEGREE_PROGRAM] ADD CONSTRAINT [PK__DM_SCHTEACH_DEGREE_PROGRAM] PRIMARY KEY CLUSTERED ([id], [SEQ]) ON [PRIMARY]
GO
