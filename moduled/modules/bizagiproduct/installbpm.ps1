Param(
    [parameter(mandatory=$true)][string]$componentName,
    [parameter(mandatory=$true)][string]$channel,
    [parameter(mandatory=$true)][string]$machineName,
    [parameter(mandatory=$true)][string]$dnsdb,
    [parameter(mandatory=$true)][string]$providerdb,
    [parameter(mandatory=$true)][string]$domain,
    [parameter(mandatory=$true)][string]$username
) 

if($componentName -ne "bizagistudio"){
    Install-Bizagi -componentName $componentName -channel $channel -physicalPath C:\Bizagi\Enterprise\Projects -environmentName RNF -connectionString "$dnsdb" -database $providerdb
} else {
    Install-Bizagi -componentName $componentName -channel $channel
}