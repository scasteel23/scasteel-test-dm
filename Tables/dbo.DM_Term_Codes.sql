CREATE TABLE [dbo].[DM_Term_Codes]
(
[Term_Code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Term_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Term_Start_Date] [datetime] NOT NULL,
[Term_End_Date] [datetime] NOT NULL,
[Academic_Year_Code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Term_Type_Code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Term_Effective_Date] [datetime] NOT NULL,
[Term_Post_Date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DM_Term_Codes] ADD CONSTRAINT [PK_DM_Term_Codes] PRIMARY KEY CLUSTERED ([Term_Code]) ON [PRIMARY]
GO
