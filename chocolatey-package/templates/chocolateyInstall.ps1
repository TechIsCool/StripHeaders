$package = 'stripheaders'

$launch_path = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$choco_params = @{
  PackageName = $package;
  FileType       = 'msi';
  SilentArgs     = '/qb'
  file           = "$launch_path\..\binaries\##FILE##";
  file64         = "$launch_path\..\binaries\##FILE##";
  checksum       = '##SHA256##'
  checksumType   = 'sha256'
  checksum64     = '##SHA256##'
  checksumType64 = 'sha256'
  ValidExitCodes = @(0)
}

Write-Warning "IIS will not be restarted. Please do so manually."
Install-ChocolateyPackage @choco_params