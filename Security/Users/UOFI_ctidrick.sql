IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\ctidrick')
CREATE LOGIN [UOFI\ctidrick] FROM WINDOWS
GO
CREATE USER [UOFI\ctidrick] FOR LOGIN [UOFI\ctidrick]
GO
