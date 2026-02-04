CREATE TABLE [dbo].[DM_Shadow_Monitoring_Reference]
(
[Table_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Download_Datetime] [datetime] NULL,
[Current_Indicator] [bit] NULL CONSTRAINT [DF_DM_Shadow_Monitoring_Reference_Current_Indicator] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DM_Shadow_Monitoring_Reference] ADD CONSTRAINT [PK_DM_Shadow_Monitoring_Reference_1] PRIMARY KEY CLUSTERED ([Table_Name]) ON [PRIMARY]
GO
