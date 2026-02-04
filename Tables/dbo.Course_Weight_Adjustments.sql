CREATE TABLE [dbo].[Course_Weight_Adjustments]
(
[Facstaff_ID] [int] NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TERM_CD] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_ID] [int] NULL,
[CRS_SUBJ_CD] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRS_NBR] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NBR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orig_Section_Weight] [float] NULL,
[Num_Instr] [int] NULL,
[Orig_Instr_Section_Load] [float] NULL,
[Matching_Sections] [int] NULL,
[Multiplier] [float] NULL,
[New_Section_Weight] [float] NULL,
[New_Instr_Section_Load] [float] NULL,
[Notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
