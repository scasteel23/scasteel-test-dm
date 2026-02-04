CREATE TABLE [dbo].[AACSB_Table_Log]
(
[Log_ID] [int] NOT NULL IDENTITY(1, 1),
[Table_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Create_Datetime] [datetime] NOT NULL,
[Notes] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
