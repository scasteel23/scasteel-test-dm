CREATE TABLE [dbo].[webservices_requests]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[url] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[post] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[response] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NOT NULL CONSTRAINT [ai_webservices_log_timestamp] DEFAULT (getdate()),
[process] [int] NULL,
[initiated] [datetime] NULL,
[completed] [datetime] NULL,
[processed] [datetime] NULL,
[dependsOn] [int] NULL,
[SP_Error] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[webservices_requests] ADD CONSTRAINT [ai_webservices_log_method] CHECK (([method]='DELETE' OR [method]='POST' OR [method]='PUT' OR [method]='GET'))
GO
ALTER TABLE [dbo].[webservices_requests] ADD CONSTRAINT [PK__webservi__3213E83FFD310905] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[webservices_requests] ADD CONSTRAINT [FK__webservic__depen__1DE57479] FOREIGN KEY ([dependsOn]) REFERENCES [dbo].[webservices_requests] ([id])
GO
