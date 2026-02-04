CREATE TABLE [dbo].[_UPLOADED_DM_RESPROG]
(
[Create_Datetime] [datetime] NULL,
[ID] [int] NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_START] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTY_END] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSDB_ID] [int] NULL
) ON [PRIMARY]
GO
