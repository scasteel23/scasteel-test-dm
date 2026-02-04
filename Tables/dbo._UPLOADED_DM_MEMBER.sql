CREATE TABLE [dbo].[_UPLOADED_DM_MEMBER]
(
[Create_Datetime] [datetime] NULL,
[ID] [int] NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORGABBR] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_ID] [int] NULL
) ON [PRIMARY]
GO
