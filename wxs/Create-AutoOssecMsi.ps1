#REQUIRES -Version 2.0
<#
.SYNOPSIS
    Uses the WiX Toolset to create an msi.
.NOTES
    File Name      : Create-MsiForAutoOSSEC.ps1
    Author         : Binary Defense Systems
    Prerequisite   : WiX Toolset v3.10
    Copyright 2015 through 2016 to Binary Defense Systems, LLC
.LINK
    WiX Toolset Can be found at:
    http://wixtoolset.org/
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False, Position=1)]
    [string]$Address = $(Read-Host "What is the IP Address where you will be running auto_server.py?")
)

If ([string]::IsNullOrEmpty(${Address})) {
    Write-Host "FAIL: An IP Address must be specified."
    Exit 3
}

$AddressParsed = $Null
$AddressIsValid = [System.Net.IPAddress]::tryparse($Address,[ref] $AddressParsed)
If (-Not $AddressIsValid) {
    Write-Host "FAIL: A Valid IP Address must be specified."
    Exit 2
}

Write-Host "MSI will be built for Address: ${Address}`n"

Write-Host -NoNewLine "Locating WiX Toolset...   "
If (Test-Path 'C:\Program Files\WiX Toolset v3.10\bin') {
    $WiX_BinRoot = 'C:\Program Files\WiX Toolset v3.10\bin'
} ElseIf (Test-Path 'C:\Program Files (x86)\WiX Toolset v3.10\bin') {
    $WiX_BinRoot = 'C:\Program Files (x86)\WiX Toolset v3.10\bin'
} Else {
    Write-Host "FAIL: Unable to locate WiX Toolset."
    Exit 1
}
Write-Host "located."

Write-Host -NoNewLine "Compiling...              "
& "${WiX_BinRoot}\candle.exe" -dServerAddress="${Address}" .\auto_ossec.wxs | Out-Null
Write-Host "compiled."

Write-Host -NoNewLine "Linking...                "
& "${WiX_BinRoot}\light.exe" -spdb -out "auto_ossec-${Address}.msi" auto_ossec.wixobj | Out-Null
Write-Host "linked."

Write-Host -NoNewLine "Cleaning up...            "
Remove-Item auto_ossec.wixobj | Out-Null
Write-Host "cleaned up."
