CREATE TABLE [dbo].[FSDB_DM_Upload_Activity_Email_Notification]
(
[Activity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Email_Address] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Create_Datetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_DM_Upload_Activity_Email_Notification] ADD CONSTRAINT [PK_FSDB_DM_Upload_Activity_Email_Notification] PRIMARY KEY CLUSTERED ([Activity], [Email_Address]) ON [PRIMARY]
GO
