CREATE TABLE [dbo].[_DM_PCI_For_Name_Update]
(
[userid] [bigint] NULL,
[id] [bigint] NOT NULL,
[surveyID] [bigint] NULL,
[termID] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PFNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PLNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BUS_FACULTY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIVE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KEEP_ACTIVE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCI_Reset_PName] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_Update_Name] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_PCI_For_Name_Update] ADD CONSTRAINT [PK__DM_PCI_For_Name_Update] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
