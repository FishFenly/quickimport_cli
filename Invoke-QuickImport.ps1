<#
.SYNOPSIS
   Import drivers or packages into SCCM in a standard format
.DESCRIPTION
   ## Prerequisite - Download driver pack from vendor site and extract locally ##
   This tool will do the following:
    - Move source to set standard location, create folder structure if required
    - Create a driver package
    - Import into SCCM
    - Add to new driver package
    - Distribute driver package
.NOTES
    FileName:   Invoke-QuickImportCli.ps1
    Author:     Joseph Fenly
    Created:    19-01-2017
    Version:    1.0

    Change Log: 1.0 - Initial Commit
                1.1 - Functionality added, pre-testing
#>
if(Test-Path "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"){
    Write-Host "INFO: Successfully detected SCCM Powershell Module" -ForegroundColor Yellow
}
else{
    Write-Host "ERROR: SCCM Powershell Module could not be found. Please run this on a device with the SCCM console installed." -ForegroundColor Red
    Exit
}
$siteServer = ""
$siteCode = "NUK:"
$drvroot = ""
$dps = "$siteServer",""
Write-Host "INFO: Establishing connection to CM Site Server" -ForegroundColor Yellow
try{
    Test-Connection $siteServer -ea Stop | Out-Null
    Write-Host "INFO: Connection successfully established" -ForegroundColor Yellow
}
catch{
    Write-Host "ERROR: Connection could not be established" -ForegroundColor Red
}
function get-cmconnection{
    $modulePath = (($env:SMS_ADMIN_UI_PATH).Substring(0,$env:SMS_ADMIN_UI_PATH.Length-5)) + '\ConfigurationManager.psd1'
    Import-Module -Name $modulePath
    Get-Module -Name ConfigurationManager
    Set-Location $siteCode
}
function set-drvsource{
    Write-Host "INFO: Querying Driver Source" -ForegroundColor Yellow
    if(Test-Path $drvpath){
	Write-Host "ERROR: Driver source already exists" -ForegroundColor Yellow
	Exit
    }
    Write-Host "INFO: Creating standard folder structure" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$drvpath"
    New-Item -ItemType Directory -Path "$drvpath\Source"
    New-Item -ItemType Directory -Path "$drvpath\Package"
    Write-Host "INFO: Moving local source to new source" -ForegroundColor Yellow
    Move-Item $src "$drvpath\Source" -Recurse
}
function set-drvcatagory{
    New-CMCategory -CategoryType DriverCategories -Name $drvpath -ea SilentlyContinue
}
function new-drvpackage{
    if(Get-CMDriverPackage -Name $path -ea SilentlyContinue){
	Write-Host "ERROR: Driver Package already exists, exiting script" -ForegroundColor Red
	Exit
    }
    New-CMDriverPackage -Name $path -path "$path\Package" -PackageSourceType StorageDirect
    $drvpkg = Get-CMDriverPackage -name $path
    return $drvpkg
}
function distribute-drvpackage{
    Write-Host "INFO: Distributing driver packages to Distribution Points" -ForegroundColor Yellow
    try{
	Start-CMContentDistribution -DriverPackageName $pkg -DistributionPointName $dps | Out-Null
    }
    catch{
	Write-Host "ERROR: Failed to distribute content" -ForegroundColor
    }
}
function import-drvsrc{
    set-drvsource
    try{
	Write-Host "INFO: Attempting to retrieve drivers from source" -ForegroundColor Yellow
	$drivers = Get-ChildItem "$drvpath\Source" -Recurse -Filter “*.inf”
    }
    catch{
	Write-Host "ERROR: Could not retrieve driver files from source" -ForegroundColor Red
	Exit
    }
    Write-Host "INFO: Driver files located" -ForegroundColor Yellow
    Write-Host "INFO: Connecting to SCCM powershell environment" -ForegroundColor Yellow
    try{
	get-cmconnection
    }
    catch{
	Write-Host "ERROR: Could not connect to SCCM PS Module, exiting script" -ForegroundColor Red
	Exit
    }
    Write-Host "INFO: Successfully connected to SCCM powershell environment" -ForegroundColor Yellow
    Write-Host "INFO: Creating new driver package"
    $pkg = new-drvpackage
    $cat = set-drvcatagory
    Write-Host "INFO: Attempting to import driver files" -ForegroundColor Yellow
    foreach($d in $drivers){
	Import-CMDriver -UncFileLocation $i.FullName -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $True -DriverPackage $pkg  -AdministrativeCategory $cat
    }
    Write-Host "INFO: Driver import complete" -ForegroundColor Yellow
    distribute-drvpackage
}
Write-Host "INFO: Gathering Driver Information, please provide the following" -ForegroundColor Yellow
$src = Read-Host "Please provide local driver source path"
$vendor = Read-Host "Device Vendor eg. DELL, HP, Microsoft"
$dmd = Read-Host "Device Model eg. HP Elitebook 840 G3"
$dos = Read-Host "Operating System eg. W7 or W10"
$dac = Read-Host "x64 or x86"
$drvpath = "$drvroot\$vendor"+" "+"$dmd"+" "+"$dos"+" "+"$dac"
Write-Host "INFO: Driver Information stored" -ForegroundColor Yellow
if($src -eq "" -or $vendor -eq "" -or $dmd -eq "" -or $dos -eq "" -or $dac -eq ""){
    Write-Host "ERROR: Required information has not been provided. Please retry and ensure all information is complete" -ForegroundColor Red
    Exit
}
import-drvsrc
Set-Location C:
