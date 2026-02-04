IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\business-w-dsquery')
CREATE LOGIN [UOFI\business-w-dsquery] FROM WINDOWS
GO
CREATE USER [UOFI\business-w-dsquery] FOR LOGIN [UOFI\business-w-dsquery]
GO
