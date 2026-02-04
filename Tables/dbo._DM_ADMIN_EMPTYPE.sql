CREATE TABLE [dbo].[_DM_ADMIN_EMPTYPE]
(
[id] [bigint] NULL,
[userid] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AC_YEAR] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPTYPE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQ] [int] NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
