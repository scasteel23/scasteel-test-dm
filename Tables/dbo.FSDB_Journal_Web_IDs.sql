CREATE TABLE [dbo].[FSDB_Journal_Web_IDs]
(
[Journal_Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Journal_Name_Short] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active_Indicator] [int] NOT NULL CONSTRAINT [DF_FSDB_Journal_Web_IDs_Active_Indicator] DEFAULT ((1)),
[Create_Datetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_Journal_Web_IDs] ADD CONSTRAINT [PK_FSDB_Journal_Web_IDs] PRIMARY KEY CLUSTERED ([Journal_Name]) ON [PRIMARY]
GO
