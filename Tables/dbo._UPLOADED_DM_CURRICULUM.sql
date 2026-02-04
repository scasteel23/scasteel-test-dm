CREATE TABLE [dbo].[_UPLOADED_DM_CURRICULUM]
(
[Create_Datetime] [datetime] NULL,
[ID] [int] NULL,
[FACSTAFFID] [int] NOT NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL
) ON [PRIMARY]
GO
