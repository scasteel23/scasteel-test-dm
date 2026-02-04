CREATE TABLE [dbo].[BUS_ICES]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Facstaff_ID] [int] NULL,
[TERM_CD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TERM] [int] NULL,
[CRS_SUBJ_CD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_NBR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NBR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_TITLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Respondents] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICES1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICES2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First_Name_Initial] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ROW_ID] [int] NULL,
[new_LEVEL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_SECT_NBR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ENROLL] [int] NULL,
[new_SCHED_TYPE_DESC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_CRS_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_CHOUR] [decimal] (10, 3) NULL,
[new_Single_Section_Indicator] [bit] NULL CONSTRAINT [DF_BUS_ICES_new_Single_Section_Indicator] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUS_ICES] ADD CONSTRAINT [PK_BUS_ICES] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
