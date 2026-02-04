CREATE TABLE [dbo].[_UPLOADED_DM_EDUCATION]
(
[Create_Datetime] [datetime] NULL,
[ID] [int] NULL,
[FACSTAFFID] [int] NOT NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCHOOL] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAMPUS] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOCATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YR_COMP] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LEVEL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAJOR] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDS] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUPPAREA] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DISSTITLE] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DISSAREA] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DISSADVISOR] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DISTINCTION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIGHEST] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_PROFILE_ORDER] [int] NULL,
[FSDB_ID] [int] NULL
) ON [PRIMARY]
GO
