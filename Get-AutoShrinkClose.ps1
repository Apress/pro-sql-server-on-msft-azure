Param(
	
   [Parameter(Mandatory=$True)]
   [string]$sqlserver
) 
$RulePass = 1
$sqlquery = "select name, is_auto_close_on, is_auto_shrink_on from sys.databases where is_auto_close_on = 1 or is_auto_shrink_on = 1"
$sqlDBs = Invoke-Sqlcmd -ServerInstance $sqlserver -Query $sqlquery

foreach ($db in $sqlDBs)
{
    if ($db.is_auto_close_on -eq "1")
    {
        Write-Host "[ERR] Database" $db.name "has AUTO CLOSE enabled" -ForegroundColor Red
        $RulePass = 0
    }
    if ($db.is_auto_shrink_on -eq "1")
    {
        Write-Host "[ERR] Database" $db.name "has AUTO SHRINK enabled" -ForegroundColor Red
        $RulePass = 0
    }
}

if ($RulePass -eq 1)
{
    Write-Host "[INFO] No databases found which have AUTO CLOSE or AUTO SHRINK property enabled" -ForegroundColor Green
}

