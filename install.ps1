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
Install-Bizagi -componentName SCHEDULER -channel $channel -physicalPath C:\Bizagi\Enterprise\Projects -environmentName RNFScheduler -connectionString $dnsdb -database $providerdb