CREATE TABLE [dbo].[FSDB_Rank_Codes]
(
[Rank_ID] [int] NOT NULL,
[Rank_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Faculty_Rank_Indicator] [bit] NULL,
[Tenure_Track_Indicator] [bit] NULL,
[Tenure_Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
