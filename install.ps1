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
Install-Bizagi -componentName ""$componentName"" -channel ""$channel"" -physicalPath ""C:\Bizagi\Enterprise\Projects"" -environmentName ""RNF"" -connectionString "' "$dnsdb" '" -database ""$providerdb""

$dnsMachine = "{0}.eastus.cloudapp.azure.com" -f $machineName
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $dnsMachine
$Thumbprint = (Get-ChildItem -Path cert:\localmachine\my  | Where-Object {$_.Subject -Match "CN=$dnsMachine"} ).Thumbprint
$port= "5986"
cmd /c "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port=""$port"" ;Hostname=""$dnsMachine"" ;CertificateThumbprint=""$Thumbprint""}"
#winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port="5986" ;Hostname=$dnsMachine ;CertificateThumbprint=$Thumbprint}