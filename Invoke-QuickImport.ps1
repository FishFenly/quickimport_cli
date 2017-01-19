<#
.SYNOPSIS
   Import drivers or packages into SCCM in a standard format
.DESCRIPTION
   This tool will do the following:
    - Move source to set standard location, create folder structure if required
    - Import into SCCM
    - 
.PARAMETER

.PARAMETER

.EXAMPLE

.NOTES
    FileName:   Invoke-QuickImportCli
    Author:     Joseph Fenly
    Created:    2017-01-19
    Version:    1.0

    Change Log: 1.0 - Initial Commit
#>
$siteServer = "dur-vmsccm-03.waterstons.local"
$drvRoot = "\\dur-vmfp-02\SCCM_Package_Sources\Driver_Source"
$pkgRoot = "\\dur-vmfp-02\SCCM_Package_Sources\Packages"
Begin{
    function get-connect{
	Write-Host "INFO: Establishing connection to CM Site Server" -ForegroundColor Yellow
	try{
	    Test-Connection $siteServer -ea Stop | Out-Null
	    Write-Host "INFO: Connection successfully established" -Foreground Yellow
	}
	catch{
	    Write-Host "ERROR: Connection could not be established" -ForegroundColor Red
	}
    }
    function get-drvsrc{
	Write-Host "INFO: Gathering Driver Information, please provide the following"
	$dvr = Read-Host "Device Vendor eg. HP or DELL"
	$dmd = Read-Host "Device Model eg. Elitebook 840 G3"
	$dos = Read-Host "Operating System"
	$dac = Read-Host "x64 or x86"
	Write-Host "INFO: Driver Information stored"
    if(Test)
    }

}
Process{

}
End{

}
 
