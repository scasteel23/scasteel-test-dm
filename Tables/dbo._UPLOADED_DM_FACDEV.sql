CREATE TABLE [dbo].[_UPLOADED_DM_FACDEV]
(
[Create_Datetime] [datetime] NULL,
[ID] [int] NULL,
[FACSTAFFID] [int] NOT NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPEOTHER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHOURS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCOPE_LOCALE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_START] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTM_END] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_ID] [int] NULL
) ON [PRIMARY]
GO
