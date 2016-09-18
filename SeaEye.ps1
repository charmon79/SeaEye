<#
    Project SeaEye: Database continuous integration for Microsoft SQL Server, done exclusively with
    native Powershell, .NET, and SMO components which are available out of the box with SQL Server.
    No third party software or special libraries required!
#>

<#
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
#>

# TODO: turn these into args
$SqlScriptDir = 'C:\SeaEye_Test'
$TargetDBName = 'AdventureWorks2012'
$SqlServerName = '(local)'

set-psdebug -strict
$ErrorActionPreference = "stop"

Import-Module Sqlps -DisableNameChecking

$scripts = Get-ChildItem $SqlScriptDir | Where-Object {$_.Name -like "$TargetDBName*"}

$ConnectionString = "Server=$SqlServerName;Database=$TargetDBName;Integrated Security=True;Application Name = 'Powershell (SeaEye Database Migration)'"

# Connect to the database
Try {
    $message = "Connecting to database [$TargetDBName] on server $SqlServerName..."
    Write-Host $message

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server
    $SqlServer.ConnectionContext.ConnectionString = $ConnectionString
    $SqlServer.ConnectionContext.StatementTimeout = 1200 # 20 minutes, allowing time for occasional long-running scripts

    #test the connection
    $SqlServer.Version | Out-Null
}
Catch [System.Data.SqlClient.SqlException]{
    Write-Error "Error connecting to database:`n$_"
    BREAK
}

# Begin a transaction. We want to be able to roll back if a script fails so we leave the database in a consistent state.
$SqlServer.ConnectionContext.BeginTransaction()

Try {
    # Iterate through scripts in $scripts
    $scripts | sort Name |
        ForEach-Object {
            $scriptName = $_.Name

            # test whether the script has previously executed (skip it if so)
            $SqlCmd = "EXEC SeaEye.DatabaseVersion_CheckScriptExists '$scriptName'"
            $exists = $SqlServer.ConnectionContext.ExecuteScalar($SqlCmd)

            if ($exists -eq $false) { `  # if the script doesn't exist in the database version history table, run it

                $message = "Running script: "+$_.Name+"..."
                Write-Host $message
        
                $file = New-Object System.IO.StreamReader -ArgumentList $_.FullName
                $SqlCmd = $file.ReadToEnd()
                $SqlServer.ConnectionContext.ExecuteNonQuery($SqlCmd) | Out-Null
                $file.Close()

                # log the execution of this script in the database version history table
                $SqlCmd = "EXEC SeaEye.DatabaseVersion_Insert '$scriptName'"
                $SqlServer.ConnectionContext.ExecuteNonQuery($SqlCmd) | Out-Null
            }

        }

    $SqlServer.ConnectionContext.CommitTransaction()
    Write-Output "All scripts were applied successfully!"
}
Catch {
    # One of the scripts failed to run, so we need to roll back the transaction.
    Write-Error "Error in script: $scriptName`n$_"
    $SqlServer.ConnectionContext.RollBackTransaction()
    Write-Warning "Transaction rolled back. Database changes not applied."
}
Finally {
    # Close the door behind us like a good house guest.
    $SqlServer.ConnectionContext.Disconnect()
}
