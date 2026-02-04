IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\jonker')
CREATE LOGIN [UOFI\jonker] FROM WINDOWS
GO
CREATE USER [uofi\jonker] FOR LOGIN [UOFI\jonker]
GO
