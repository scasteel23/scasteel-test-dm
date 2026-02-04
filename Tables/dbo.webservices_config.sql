CREATE TABLE [dbo].[webservices_config]
(
[linked] [bit] NULL,
[screen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sub] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[col] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[node_path] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
