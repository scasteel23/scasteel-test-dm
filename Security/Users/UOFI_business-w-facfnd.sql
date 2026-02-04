IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\business-w-facfnd')
CREATE LOGIN [UOFI\business-w-facfnd] FROM WINDOWS
GO
CREATE USER [UOFI\business-w-facfnd] FOR LOGIN [UOFI\business-w-facfnd]
GO
