CREATE TABLE [dbo].[webservices_activity_logs]
(
[webservices_activity_logs_ID] [int] NOT NULL IDENTITY(1, 1),
[Screen_Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Network_ID] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[webservices_activity_logs] ADD CONSTRAINT [PK_FSDB_Logs] PRIMARY KEY CLUSTERED ([webservices_activity_logs_ID]) ON [PRIMARY]
GO
