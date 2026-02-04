CREATE TABLE [dbo].[WP_People_Directory_List]
(
[Dir_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DIR_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DIR_description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Area_dir_ind] [bit] NULL,
[Site_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shortcode_ID] [int] NULL,
[Test_Shortcode_ID] [int] NULL,
[DIR_tab_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
