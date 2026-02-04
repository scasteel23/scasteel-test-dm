CREATE TABLE [dbo].[_UPLOAD_Web_IDs]
(
[userid] [int] NULL,
[USERNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Attribute] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[FACSTAFFID] [int] NULL,
[Value] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Preferred_Attribute_Indicator] [bit] NOT NULL CONSTRAINT [DF_Web_IDs_Pereferred_ID_Indicator] DEFAULT ((0)),
[Create_Datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_UPLOAD_Web_IDs] ADD CONSTRAINT [PK_Facstaff_Web_IDs] PRIMARY KEY CLUSTERED ([USERNAME], [Attribute], [Sequence]) ON [PRIMARY]
GO
