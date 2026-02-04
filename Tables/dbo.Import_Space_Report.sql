CREATE TABLE [dbo].[Import_Space_Report]
(
[Room] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Building] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Area] [float] NULL,
[Function] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UIN] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Occupant] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Capacity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vacant] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exterior Window] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Occupant Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Spring 2022] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Import_Datetime] [datetime] NULL CONSTRAINT [DF_Import_Space_Report_Import_Datetime] DEFAULT (getdate())
) ON [PRIMARY]
GO
