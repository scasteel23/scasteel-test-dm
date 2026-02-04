IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\Business-W-facstaff')
CREATE LOGIN [UOFI\Business-W-facstaff] FROM WINDOWS
GO
CREATE USER [UOFI\Business-W-facstaff] FOR LOGIN [UOFI\Business-W-facstaff]
GO
