#!/usr/bin/env pwsh
# Copyright (c) 2025 Roger Brown.
# Licensed under the MIT License.

param(
	$ProductVersion = '1.0.0',
	$CertificateThumbprint = '601A8B683F791E51F647D34AD102C38DA4DDB65F'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

trap
{
	throw $PSItem
}

$CompanyName = 'rhubarb-geek-nz'
$ProductName = 'psprofile'

$codeSignCertificate = Get-ChildItem -path Cert:\ -Recurse -CodeSigningCert | Where-Object { $_.Thumbprint -eq $CertificateThumbprint }

if ($codeSignCertificate.Count -ne 1)
{
	Write-Error "Error with certificate - $CertificateThumbprint"
}

$ArchList = @(
	@{
		Arch = 'x86'
		UpgradeCode = '9CEB1533-5EFD-41DE-9769-40B93D65C42D'
		Is64bit = $false
		Win64 = 'no'
		Platform = 'x86'
		InstallerVersion = '200'
		EnvironmentGuid = 'AF8D534D-F8C9-447E-A353-EBFA714DB8B0'
	},
	@{
		Arch = 'x64'
		UpgradeCode = '3F3E5B8B-CA7C-477F-BC18-2ADEB1C1AF32'
		Is64bit = $true
		Win64 = 'yes'
		Platform = 'x64'
		InstallerVersion = '200'
		EnvironmentGuid = '06D38301-F44D-4373-AD46-B7491B3F6D15'
	},
	@{
		Arch = 'arm64'
		UpgradeCode = '8599BB37-56F8-4766-92FB-8C87152ABDC0'
		Is64bit = $true
		Win64 = 'yes'
		Platform = 'arm64'
		InstallerVersion = '500'
		EnvironmentGuid = 'CBED3F84-0B3D-439D-B625-4EF396A727DF'
	}
)

foreach ($Arch in $ArchList)
{
	$MsiStem = "$CompanyName-$ProductName-$ProductVersion-win-$($Arch.Arch)"

@'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="$(var.ProductName) ($(var.Platform))" Language="1033" Version="$(var.ProductVersion)" Manufacturer="$(var.CompanyName)" UpgradeCode="$(var.UpgradeCode)">
    <Package InstallerVersion="$(var.InstallerVersion)" Compressed="yes" InstallScope="perMachine" Platform="$(var.Platform)" Description="$(var.ProductName) $(var.ProductVersion) $(var.Platform)" Comments="PowerShell Environment Variables" />
    <MediaTemplate EmbedCab="yes" />
    <Upgrade Id="{$(var.UpgradeCode)}">
      <UpgradeVersion Maximum="$(var.ProductVersion)" Property="OLDPRODUCTFOUND" OnlyDetect="no" IncludeMinimum="yes" IncludeMaximum="no" />
    </Upgrade>
    <InstallExecuteSequence>
      <RemoveExistingProducts After="InstallInitialize" />
      <WriteEnvironmentStrings/>
    </InstallExecuteSequence>
    <DirectoryRef Id="TARGETDIR">
      <Component Id ="setEnviroment" Guid="$(var.EnvironmentGuid)" Win64="$(var.Win64)">
        <Environment Id="POWERSHELL_TELEMETRY_OPTOUT" Action="set" Name="POWERSHELL_TELEMETRY_OPTOUT" Permanent="no" System="yes" Value="true" />
        <Environment Id="POWERSHELL_UPDATECHECK" Action="set" Name="POWERSHELL_UPDATECHECK" Permanent="no" System="yes" Value="Off" />
      </Component>
    </DirectoryRef>
    <Feature Id="EnvironmentFeature" Title="Environment" Level="1" Absent="disallow" AllowAdvertise="no" Display="hidden" >
      <ComponentRef Id="setEnviroment"/>
    </Feature>
  </Product>
  <Fragment>
    <Directory Id="TARGETDIR" Name="SourceDir">
    </Directory>
  </Fragment>
</Wix>
'@ | Set-Content -LiteralPath "$MsiStem.wxs"

	& "$ENV:WIX\bin\candle.exe" `
		"$MsiStem.wxs" `
		-nologo `
		-ext WixUtilExtension `
		"-dWin64=$($Arch.Win64)" `
		"-dPlatform=$($Arch.Platform)" `
		"-dUpgradeCode=$($Arch.UpgradeCode)" `
		"-dInstallerVersion=$($Arch.InstallerVersion)" `
		"-dEnvironmentGuid=$($Arch.EnvironmentGuid)" `
		"-dCompanyName=$CompanyName" `
		"-dProductName=$ProductName" `
		"-dProductVersion=$ProductVersion"

	If ( $LastExitCode -ne 0 )
	{
		Exit $LastExitCode
	}

	& "$ENV:WIX\bin\light.exe" -sw1076 -nologo -cultures:null -out "$MsiStem.msi" "$MsiStem.wixobj" -ext WixUtilExtension

	If ( $LastExitCode -ne 0 )
	{
		Exit $LastExitCode
	}

	$null = Set-AuthenticodeSignature -FilePath "$MsiStem.msi" -HashAlgorithm 'SHA256' -Certificate $codeSignCertificate -TimestampServer 'http://timestamp.digicert.com'

	foreach ($WixExt in 'wxs','wixobj','wixpdb')
	{
		Remove-Item "$MsiStem.$WixExt"
	}
}
