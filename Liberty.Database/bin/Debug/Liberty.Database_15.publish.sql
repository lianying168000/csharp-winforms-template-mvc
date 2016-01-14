﻿/*
Deployment script for Liberty

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Liberty"
:setvar DefaultFilePrefix "Liberty"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Dropping FK_UsersInRoles_ToRoles...';


GO
ALTER TABLE [dbo].[UsersInRoles] DROP CONSTRAINT [FK_UsersInRoles_ToRoles];


GO
PRINT N'Dropping FK_UsersInRoles_ToUsers...';


GO
ALTER TABLE [dbo].[UsersInRoles] DROP CONSTRAINT [FK_UsersInRoles_ToUsers];


GO
/*
The column [dbo].[UsersInRoles].[Id] on table [dbo].[UsersInRoles] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.
*/
GO
PRINT N'Starting rebuilding table [dbo].[UsersInRoles]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_UsersInRoles] (
    [Id]     UNIQUEIDENTIFIER NOT NULL,
    [UserId] UNIQUEIDENTIFIER NOT NULL,
    [RoleId] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[UsersInRoles])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_UsersInRoles] ([UserId], [RoleId])
        SELECT [UserId],
               [RoleId]
        FROM   [dbo].[UsersInRoles];
    END

DROP TABLE [dbo].[UsersInRoles];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_UsersInRoles]', N'UsersInRoles';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating FK_UsersInRoles_ToRoles...';


GO
ALTER TABLE [dbo].[UsersInRoles] WITH NOCHECK
    ADD CONSTRAINT [FK_UsersInRoles_ToRoles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([Id]);


GO
PRINT N'Creating FK_UsersInRoles_ToUsers...';


GO
ALTER TABLE [dbo].[UsersInRoles] WITH NOCHECK
    ADD CONSTRAINT [FK_UsersInRoles_ToUsers] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);


GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[UsersInRoles] WITH CHECK CHECK CONSTRAINT [FK_UsersInRoles_ToRoles];

ALTER TABLE [dbo].[UsersInRoles] WITH CHECK CHECK CONSTRAINT [FK_UsersInRoles_ToUsers];


GO
PRINT N'Update complete.';


GO
