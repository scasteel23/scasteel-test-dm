IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\bjadhav2')
CREATE LOGIN [UOFI\bjadhav2] FROM WINDOWS
GO
CREATE USER [UOFI\bjadhav2] FOR LOGIN [UOFI\bjadhav2]
GO
