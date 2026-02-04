CREATE TABLE [dbo].[___DM_DEP]
(
[Department_ID] [int] NOT NULL,
[Department_Code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DM_Department_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Default_DEPT_CD_Mapping_Indicator] [bit] NULL,
[Academic_Department_Indicator] [bit] NOT NULL,
[EDW_Dept_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDW_Dept_CD2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDW_Dept_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active_Indicator] [bit] NULL,
[Create_Datetime] [datetime] NULL,
[Last_Update_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
