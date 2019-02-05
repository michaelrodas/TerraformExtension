Param(
    [parameter(mandatory=$true)][string]$componentName,
    [parameter(mandatory=$true)][string]$channel,
    [parameter(mandatory=$true)][string]$machineName,
    [parameter(mandatory=$true)][string]$dnsdb,
    [parameter(mandatory=$true)][string]$providerdb
) 
<#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install -y jdk8
choco install -y visualstudiocode
choco install -y packer
choco install -y terraform#> 
java -jar C:\AutoUpdateToolkit\AutoUpdateToolkit.jar
Install-Bizagi -componentName $componentName -channel $channel -physicalPath C:\Bizagi\Enterprise\Projects -environmentName RNF -connectionString $dnsdb -database $providerdb
<#$dns = "{0}.eastus.cloudapp.azure.com" -f $machineName
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $dns
$Thumbprint = (Get-ChildItem -Path cert:\localmachine\my  | Where-Object {$_.Subject -Match "CN=$dns"} ).Thumbprint
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port="5986" ;Hostname=$dns ;CertificateThumbprint=$Thumbprint}#>