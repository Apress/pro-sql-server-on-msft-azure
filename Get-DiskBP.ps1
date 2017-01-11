$VMName = "tigerninja"
$RGName = "ninja"

$LogicalDrives = @()
$PhysicalDrives = @()
$Drives = Get-WmiObject -Class Win32_DiskDrive | Select Index,SCSILogicalUnit, Path 
foreach ($drive in $Drives)
{
    $Dependent = Get-WmiObject -Class Win32_DiskDriveToDiskPartition | Where-Object {$_.Antecedent -contains $drive.Path} | Select-Object Dependent
    $TempDrive = (Get-WmiObject -Class Win32_LogicalDiskToPartition | Where-Object {$_.Antecedent -eq $Dependent.Dependent} | Select-Object Dependent).Dependent.Split("`"")[1]
    $DriveArray = $TempDrive + "," + $Drive.Index
    $LogicalDrives = $LogicalDrives + $DriveArray
    $DriveLetter= $DriveLetter + $TempDrive
}

$VM = Get-AzureRMVM -ResourceGroupName $RGName -Name $VMName 
$VMDisks = $VM.StorageProfile.DataDisks 

$sqlquery = "select distinct substring(physical_name,1,2) as drive from sys.master_files where substring(physical_name,2,1) = ':' and type = 0"
$sqlDataDrives = Invoke-Sqlcmd -ServerInstance "." -Query $sqlquery

$c = 0
 
$DriveLetter.drive | ? {$sqlDataDrives.Drive -contains $_} 
foreach ($drive in $LogicalDrives)
{
    #$drive
    $VMDisks | Where-Object {$_.Lun -eq ($drive -split ",")[1]} | Select Caching
}