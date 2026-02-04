CREATE TABLE [dbo].[DM_Area_Department_Mapping]
(
[DM_Area] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DM_Department] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DM_Area_Current] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DM_Present_Indicator] [bit] NOT NULL,
[Directory_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Directory_Active_Indicator] [bit] NULL
) ON [PRIMARY]
GO
