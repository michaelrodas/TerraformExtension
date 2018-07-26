iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install -y jdk8
choco install -y visualstudiocode
choco install -y packer
choco install -y terraform