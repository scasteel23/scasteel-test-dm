CREATE TABLE [dbo].[Import_Office_Space]
(
[DATE] [smalldatetime] NULL,
[ROOM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLDG] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEPT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UIN] [bigint] NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENTS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Special_Case] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Not_in_DM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
