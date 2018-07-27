<#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install -y jdk8
choco install -y visualstudiocode
choco install -y packer
choco install -y terraform#>
Import-Module BizagiAutomationSdk
Import-Module BizagiCISdk
Import-Module BizagiUtil
Import-Module InstallBizagi
Update-BPM -channel CURRENT
Install-Bizagi -componentName BPM -channel QA -physicalPath C:\Bizagi\Enterprise\Projects -environmentName proof
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname "rnf-ende-bpm-1.eastus.cloudapp.azure.com"
#$Thumbprint = (Get-ChildItem -Path cert:\localmachine\my  | Where-Object {$_.Subject -Match "CN=rnf-ende-bpm-1.eastus.cloudapp.azure.com"} ).Thumbprint
#winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port="5986" ;Hostname="rnf-ende-bpm-1.eastus.cloudapp.azure.com" ;CertificateThumbprint=$Thumbprint}