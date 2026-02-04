CREATE TABLE [dbo].[Temp_USERS]
(
[username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[userid] [bigint] NULL,
[Facstaff_ID] [int] NULL,
[EDW_PERS_ID] [bigint] NULL,
[UIN] [bigint] NULL,
[First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Middle_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled_Indicator] [tinyint] NULL,
[Load_Scope] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_USERS_Load_Scope] DEFAULT ('N'),
[Update_Datetime] [datetime] NOT NULL CONSTRAINT [DF__USERS__updated__1A14E395] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_USERS] ADD CONSTRAINT [PK__USERS__F3DBC573836F65CC] PRIMARY KEY CLUSTERED ([username]) ON [PRIMARY]
GO
