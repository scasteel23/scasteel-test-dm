CREATE TABLE [dbo].[_DM_ADMIN]
(
[id] [bigint] NOT NULL,
[userid] [bigint] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACSTAFFID] [int] NULL,
[EDWPERSID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AC_YEAR] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RANK] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TENURE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAFF_TYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTE] [decimal] (9, 0) NULL,
[FTE_EXTERN] [decimal] (9, 0) NULL,
[DEDMISS] [int] NULL,
[QUALIFICATION] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QUALIFICATION_BASIS] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AACSBSUFF] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JOINT_APPOINTMENT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXCLUDE_AACSB] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPDATED] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KEEP_ACTIVE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastModified] [datetime] NULL,
[Create_Datetime] [datetime] NULL,
[Download_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_DM_ADMIN] ADD CONSTRAINT [PK__DM_ADMIN] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
