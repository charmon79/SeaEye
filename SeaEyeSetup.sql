/************************************************************************************************************************
    Project SeaEye - Database migration script management for SQL Server.

    Author      :   Chris Harmon
    Date        :   2016-09-17

    This script sets up all necessary database objects used by the SeaEye solution in your database.

    SeaEye maintains a history of all Transact-SQL scripts which were executed to bring the database to
    a given version from the previous version.
	
	---------------------------------------------------------------------------------------------------
	
	MIT License

	Copyright (c) 2016 Chris Harmon

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

************************************************************************************************************************/

/*
    Create SeaEye schema if not exists. This schema will contain all objects used
    by the SeaEye solution for tracking version & script execution history.
*/
IF SCHEMA_ID('SeaEye') IS NULL
EXEC('CREATE SCHEMA [SeaEye] AUTHORIZATION [dbo];');
GO

IF OBJECT_ID('SeaEye.DatabaseVersion','U') IS NULL
CREATE TABLE SeaEye.DatabaseVersion (
    DatabaseVersionID       BIGINT          IDENTITY(1,1)   NOT NULL    CONSTRAINT PK_DatabaseVersion PRIMARY KEY CLUSTERED
,   ScriptName              NVARCHAR(255)                   NOT NULL    CONSTRAINT UQ_DatabaseVersion_ScriptName UNIQUE NONCLUSTERED
,   ExecutedTime            DATETIMEOFFSET                  NOT NULL    CONSTRAINT DF_DatabaseVersion_ExecutedTime DEFAULT SYSDATETIMEOFFSET()
,   INDEX IX_ExecutedTime NONCLUSTERED (ExecutedTime ASC)
);
GO

IF OBJECT_ID('SeaEye.DatabaseVersion_Insert','P') IS NULL
EXEC ('CREATE PROCEDURE SeaEye.DatabaseVersion_Insert AS');
GO
ALTER PROCEDURE SeaEye.DatabaseVersion_Insert
    @ScriptName NVARCHAR(255)
AS
/*
	MIT License

	Copyright (c) 2016 Chris Harmon

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SeaEye.DatabaseVersion (ScriptName)
    VALUES (@ScriptName);
END;
GO

IF OBJECT_ID('SeaEye.DatabaseVersion_CheckScriptExists','P') IS NULL
EXEC ('CREATE PROCEDURE SeaEye.DatabaseVersion_CheckScriptExists AS');
GO
ALTER PROCEDURE SeaEye.DatabaseVersion_CheckScriptExists
    @ScriptName NVARCHAR(255)
AS
/*
	MIT License

	Copyright (c) 2016 Chris Harmon

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/
BEGIN
    SET NOCOUNT ON;

    IF  EXISTS (
            SELECT  1
            FROM    SeaEye.DatabaseVersion
            WHERE   ScriptName = @ScriptName
        )
    SELECT CAST(1 AS BIT) AS Result
    ELSE
    SELECT CAST(0 AS BIT) AS Result
END;
GO