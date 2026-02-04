CREATE TABLE [dbo].[FSDB_DM_Upload_Logs]
(
[FSDB_DM_Upload_Logs_ID] [int] NOT NULL IDENTITY(1, 1),
[FACSTAFFID] [int] NULL,
[UIN] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDWPERSID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [bigint] NULL,
[BANNER_FNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BANNER_MNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BANNER_LNAME] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DM_Department_Name] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPEE_DEPT_NAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPEE_CLS_LONG_DESC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPEE_GROUP_DESC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAC_RANK_DESC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIRST_HIRE_DT] [datetime] NULL,
[CUR_HIRE_DT] [datetime] NULL,
[FIRST_WORK_DT] [datetime] NULL,
[LAST_WORK_DT] [datetime] NULL,
[Doctoral_Flag] [smallint] NULL,
[College_Sum_FTE] [int] NULL,
[Univ_Sum_FTE] [int] NULL,
[Activity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Current_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FSDB_DM_Upload_Logs] ADD CONSTRAINT [PK_FSDB_Upload_To_DM_Logs] PRIMARY KEY CLUSTERED ([FSDB_DM_Upload_Logs_ID]) ON [PRIMARY]
GO
