IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\business-powerbi')
CREATE LOGIN [UOFI\business-powerbi] FROM WINDOWS
GO
CREATE USER [uofi\business-powerbi] FOR LOGIN [UOFI\business-powerbi]
GO
