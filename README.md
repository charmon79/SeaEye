# Project SeaEye
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/charmon79/SeaEye/blob/master/LICENSE.md)

Project SeaEye: Continuous Integration for SQL Server databases using Powershell &amp; SMO

**SeaEye.ps1:** Executes migration scripts in a directory sequentially against a SQL Server database. Scripts which are executed are journaled to a table in the same database (SeaEye.DatabaseVersion). Scripts which have already been executed are thus ignored on subsequent deployments.

**SeaEyeSetup.sql:** Creates the database objects used by Project SeaEye within your database.
