$Package = 'stripheaders'
$Version = $(Get-Item -Path ENV:PRODUCTVERSION)
$FileName = "iis_stripheaders_module_${Version}.msi"

$Params = @{
  Algorithm = 'SHA256';
  LocalFile = "Installer\bin\x64\Release\${FileName}";
  Hash = '';
  ProductCode = '';
}


Write-Output `
  $Package `
  "Release Version: $Version"

New-Item `
-ItemType Directory `
-Path "$PSScriptRoot\output\binaries","$PSScriptRoot\output\tools\" `
-ErrorAction SilentlyContinue | Out-Null

$Params['Hash'] = Get-FileHash `
    -Path $Params['LocalFile'] `
    -Algorithm $Params['Algorithm']
  Write-Output "Created $OS $($Params['Algorithm']): $($Params['Hash'].Hash)"

$Params['ProductCode'] = $(.\Get-MSIFileInformation.ps1 -Path $Params['LocalFile'] -Property ProductCode)[3]
Write-Output "Found $OS ProductCode: $($Params['ProductCode'])"

Copy-Item -Path $Params['LocalFile'] -Destination "$PSScriptRoot\output\binaries\${FileName}"


$(Get-Content -Path "$PSScriptRoot\templates\$Package.nuspec") `
  -replace '##VERSION##', $Version | `
  Out-File "$PSScriptRoot\output\$Package.nuspec"
Write-Output 'Created output\$Package.nuspec'

$(Get-Content -Path "$PSScriptRoot\templates\chocolateyInstall.ps1") `
  -replace '##FILE##', $FileName `
  -replace '##SHA256##', $Params['Hash'].Hash | `
  Out-File "$PSScriptRoot\output\tools\chocolateyInstall.ps1"
Write-Output 'Created output\tools\chocolateyInstall.ps1'

$(Get-Content -Path "$PSScriptRoot\templates\chocolateyUninstall.ps1") `
  -replace '##PRODUCTCODE##', $Params['ProductCode'] | `
  Out-File "$PSScriptRoot\output\tools\chocolateyUninstall.ps1"
Write-Output 'Created output\tools\chocolateyUninstall.ps1'

Set-Item -Path ENV:NUPKG_VERSION -Value "$Version"
Set-Item -Path ENV:NUPKG -Value "$Package.$Version.nupkg"
