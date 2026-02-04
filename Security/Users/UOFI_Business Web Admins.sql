IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\Business Web Admins')
CREATE LOGIN [UOFI\Business Web Admins] FROM WINDOWS
GO
CREATE USER [UOFI\Business Web Admins] FOR LOGIN [UOFI\Business Web Admins]
GO
