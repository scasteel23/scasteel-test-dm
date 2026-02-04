CREATE TABLE [dbo].[_UPLOAD_DM_USERS]
(
[username] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[userid] [bigint] NULL,
[FacstaffID] [int] NULL,
[EDWPERSID] [bigint] NULL,
[UIN] [bigint] NULL,
[First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Middle_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled_Indicator] [tinyint] NULL,
[Record_Status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Update_Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Record_Source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Record_FTPT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seq] [int] NULL,
[Update_Datetime] [datetime] NOT NULL CONSTRAINT [DF_UPLOAD_DM_USERS] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_UPLOAD_DM_USERS] ADD CONSTRAINT [PK_UPLOAD_DM_USERS] PRIMARY KEY CLUSTERED ([username]) ON [PRIMARY]
GO
