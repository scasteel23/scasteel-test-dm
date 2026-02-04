CREATE TABLE [dbo].[DM_Shadow_Monitoring_Log]
(
[DM_Shadow_Download_Log_ID] [bigint] NOT NULL IDENTITY(1, 1),
[Table_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Download_Datetime] [datetime] NULL,
[Current_Indicator] [bit] NULL CONSTRAINT [DF_DM_Shadow_Monitoring_Log_Current_Indicator] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DM_Shadow_Monitoring_Log] ADD CONSTRAINT [PK_DM_Shadow_Monitoring_Log] PRIMARY KEY CLUSTERED ([DM_Shadow_Download_Log_ID]) ON [PRIMARY]
GO
