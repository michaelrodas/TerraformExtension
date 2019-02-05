Param(
    [parameter(mandatory=$true)][string]$componentName,
    [parameter(mandatory=$true)][string]$channel,
    [parameter(mandatory=$true)][string]$machineName,
    [parameter(mandatory=$true)][string]$dnsdb,
    [parameter(mandatory=$true)][string]$providerdb,
    [parameter(mandatory=$true)][string]$domain,
    [parameter(mandatory=$true)][string]$username
) 

$password = "$($username)ctrlr1Psw" | ConvertTo-SecureString -asPlainText -Force 
$username = "$domain\$username" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
Add-Computer -DomainName $domain -Credential $credential 

java -jar C:\AutoUpdateToolkit\AutoUpdateToolkit.jar

if($componentName -ne "bizagistudio"){
    Install-Bizagi -componentName $componentName -channel $channel -physicalPath C:\Bizagi\Enterprise\Projects -environmentName RNF -connectionString "$dnsdb" -database $providerdb
} else {
    Install-Bizagi -componentName $componentName -channel $channel
}

$dnsMachine = "{0}.eastus.cloudapp.azure.com" -f $machineName
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $dnsMachine
$Thumbprint = (Get-ChildItem -Path cert:\localmachine\my  | Where-Object {$_.Subject -Match "CN=$dnsMachine"} ).Thumbprint
$port= "5986"
cmd /c "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Port=""$port"" ;Hostname=""$dnsMachine"" ;CertificateThumbprint=""$Thumbprint""}"

Restart-Computer