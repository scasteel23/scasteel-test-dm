IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'UOFI\business-powerbi-gw')
CREATE LOGIN [UOFI\business-powerbi-gw] FROM WINDOWS
GO
CREATE USER [UOFI\business-PowerBI-GW] FOR LOGIN [UOFI\business-powerbi-gw]
GO
