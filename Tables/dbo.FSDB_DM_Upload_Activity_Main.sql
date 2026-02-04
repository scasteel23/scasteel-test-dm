CREATE TABLE [dbo].[FSDB_DM_Upload_Activity_Main]
(
[Activity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_Report_Order] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_DM_Upload_Activity_Main] ADD CONSTRAINT [PK_FSDB_DM_Upload_Activity_Main] PRIMARY KEY CLUSTERED ([Activity]) ON [PRIMARY]
GO
