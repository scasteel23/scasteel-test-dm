CREATE TABLE [dbo].[_DM_CONGRANT]
(
[id] [bigint] NOT NULL,
[Research_Grant_ID] [int] NULL,
[TITLE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SPONORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMOUNT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLASSIFICATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_REFERENCE_CREATOR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_CONGRANT] ADD CONSTRAINT [PK__DM_CONGRANT] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
