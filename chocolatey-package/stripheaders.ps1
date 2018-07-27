$Package = 'stripheaders'
$Version = $(Get-Item -Path ENV:PRODUCTVERSION).Value
$FileName = "iis_stripheaders_module_${Version}.msi"

$Params = @{
  Algorithm = 'SHA256';
  LocalFile = "$PSScriptRoot\output\binaries\${FileName}";
  Hash = '';
  ProductCode = '{25B47569-4A4A-4326-B5B0-7BD4958A58C3}';
}

Write-Output `
  $Package `
  "Release Version: $Version"

New-Item `
-ItemType Directory `
-Path "$PSScriptRoot\output\binaries","$PSScriptRoot\output\tools\" `
-ErrorAction SilentlyContinue | Out-Null

Copy-Item -Path "..\Installer\bin\x64\Release\${FileName}"  -Destination $Params['LocalFile']
Copy-Item -Path "..\LICENSE"  -Destination "$PSScriptRoot\output\LICENSE"


$Params['Hash'] = Get-FileHash `
    -Path $Params['LocalFile'] `
    -Algorithm $Params['Algorithm']
Write-Output "${FileName} $($Params['Algorithm']): $($Params['Hash'].Hash)"
"${FileName} $($Params['Algorithm']): $($Params['Hash'].Hash)" | Out-File -FilePath 'CHECKSUM.txt'

$FileProductCode = $(.\Get-MSIFileInformation.ps1 -Path $Params['LocalFile'] -Property ProductCode | Out-String)
if($FileProductCode){
  $Params['ProductCode'] = $FileProductCode.replace(' ','')
  Write-Output "Set ProductCode from File"
}
Write-Output "ProductCode: $($Params['ProductCode'])"

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

Copy-Item `
 -Path "$PSScriptRoot\output\tools\chocolateyUninstall.ps1" `
 -Destination "$PSScriptRoot\output\tools\chocolateyBeforeModify.ps1"
 Write-Output 'Created output\tools\chocolateyBeforeModify.ps1'

$(Get-Content -Path "$PSScriptRoot\templates\VERIFICATION.txt") `
  -replace '##FILE##', $FileName `
  -replace '##SHA256##', $Params['Hash'].Hash | `
  Out-File "$PSScriptRoot\output\VERIFICATION.txt"
Write-Output 'Created output\VERIFICATION.txt'


Set-Item -Path ENV:NUPKG_VERSION -Value "$Version"
Set-Item -Path ENV:NUPKG -Value "$Package.$Version.nupkg"