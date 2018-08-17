Param(
    [parameter(mandatory=$true)][string]$componentName,
    [parameter(mandatory=$true)][string]$channel,
    [parameter(mandatory=$true)][string]$machineName,
    [parameter(mandatory=$true)][string]$dnsdb
) 
<#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install -y jdk8
choco install -y visualstudiocode
choco install -y packer
choco install -y terraform#> 
java -jar C:\AutoUpdateToolkit\AutoUpdateToolkit.jar
Install-Bizagi -componentName $componentName -channel $channel -physicalPath C:\Bizagi\Enterprise\Projects -environmentName Proof - '"Persist Security Info=True;User ID=sa;Password=B1z4g1;Data Source=RNF-AUT-SQL-1;Initial Catalog=RNF;"'
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $machineName

#$Thumbprint = (Get-ChildItem -Path cert:\localmachine\my  | Where-Object {$_.Subject -Match "CN=rnf-ende-bpm-1.eastus.cloudapp.azure.com"} ).Thumbprint
#winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port="5986" ;Hostname="rnf-ende-bpm-1.eastus.cloudapp.azure.com" ;CertificateThumbprint=$Thumbprint}