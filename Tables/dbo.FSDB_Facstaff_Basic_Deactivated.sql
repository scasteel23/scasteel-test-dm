CREATE TABLE [dbo].[FSDB_Facstaff_Basic_Deactivated]
(
[FBD_ID] [int] NOT NULL IDENTITY(1, 1),
[Facstaff_ID] [int] NOT NULL,
[EDW_PERS_ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Network_ID] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Leaving_Date] [datetime] NULL,
[Update_Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_Facstaff_Basic_Deactivated] ADD CONSTRAINT [PK_FSDB_Facstaff_Basic_Deactivated] PRIMARY KEY CLUSTERED ([FBD_ID]) ON [PRIMARY]
GO
