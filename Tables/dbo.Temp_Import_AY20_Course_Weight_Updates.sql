CREATE TABLE [dbo].[Temp_Import_AY20_Course_Weight_Updates]
(
[FSID] [int] NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Term] [int] NULL,
[CRS_ID] [int] NULL,
[Subj] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nbr] [int] NULL,
[CRN] [int] NULL,
[Sect] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orig Section Weight] [float] NULL,
[Num Instr] [int] NULL,
[Orig Instr_Section Load] [float] NULL,
[# of Matching Sections] [int] NULL,
[Multiplier] [float] NULL,
[New Section Weight] [float] NULL,
[New Instr_Section Load] [float] NULL,
[Notes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
