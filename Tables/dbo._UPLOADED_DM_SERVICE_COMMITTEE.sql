CREATE TABLE [dbo].[_UPLOADED_DM_SERVICE_COMMITTEE]
(
[Create_Datetime] [datetime] NULL,
[ID] [bigint] NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [int] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG_REPORTABLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP_OTHER] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_CURRENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_ID] [int] NULL
) ON [PRIMARY]
GO
