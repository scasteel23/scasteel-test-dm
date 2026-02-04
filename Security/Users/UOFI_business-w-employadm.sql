IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\business-w-employadm')
CREATE LOGIN [UOFI\business-w-employadm] FROM WINDOWS
GO
CREATE USER [UOFI\business-w-employadm] FOR LOGIN [UOFI\business-w-employadm]
GO
