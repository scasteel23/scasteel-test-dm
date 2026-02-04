CREATE TABLE [dbo].[webservices_logs]
(
[webservices_logs_id] [int] NOT NULL IDENTITY(1, 1),
[webservices_requests_id] [int] NULL,
[Post_Or_Get] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[What_Loaded] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOAD_STATUS_CD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOAD_STATUS_DESC] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POST_DATE] [datetime] NULL
) ON [PRIMARY]
GO
