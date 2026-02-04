CREATE TABLE [dbo].[Admin_App_Employee_View2]
(
[Facstaff_ID] [int] NOT NULL,
[EDW_PERS_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UIN] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Network_ID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Banner_First_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Banner_Preferred_First_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Banner_Middle_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Banner_Last_Name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Display_First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Display_Middle_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Display_Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Employee_Class_Code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Titles] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
