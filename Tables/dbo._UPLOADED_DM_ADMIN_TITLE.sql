CREATE TABLE [dbo].[_UPLOADED_DM_ADMIN_TITLE]
(
[id] [bigint] NULL,
[userid] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AC_YEAR] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQ] [int] NULL,
[ENDOWED_POS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ROLE_OTHER] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE_CURRENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
