CREATE TABLE [dbo].[_DM_USERS]
(
[username] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[userid] [bigint] NULL,
[FacstaffID] [int] NULL,
[EDWPERSID] [bigint] NULL,
[UIN] [bigint] NULL,
[First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Middle_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DM_USERS_Load_Scope] DEFAULT ('N'),
[Enabled_Indicator] [tinyint] NULL,
[Service_Account_Indicator] [bit] NULL,
[Update_Datetime] [datetime] NOT NULL CONSTRAINT [DF_DM_USERS] DEFAULT (getdate()),
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_USERS] ADD CONSTRAINT [PK_DM_USERS] PRIMARY KEY CLUSTERED ([username]) ON [PRIMARY]
GO
