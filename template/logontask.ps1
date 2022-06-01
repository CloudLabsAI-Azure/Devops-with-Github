
Set-ExecutionPolicy -ExecutionPolicy bypass -Force
Start-Transcript -Path C:\WindowsAzure\Logs\extensionlog.txt -Append
Write-Host "Logon-task-started" 

$DeploymentID = $env:DeploymentID

Start-Process C:\Packages\extensions.bat
Write-Host "Bypass-Execution-Policy" 
 
choco install docker-desktop --version=4.7.0
Write-Host "Docker-install"



[Environment]::SetEnvironmentVariable("Path", $env:Path+";C:\Users\demouser\AppData\Roaming\npm\node_modules\azure-functions-core-tools\bin","User")

cd C:\

mkdir C:\Workspaces
cd C:\Workspaces
mkdir lab
cd lab

git clone --branch stage https://github.com/CloudLabs-MCW/MCW-Continuous-delivery-in-Azure-DevOps

mkdir mcw-continuous-delivery-lab-files
cd mcw-continuous-delivery-lab-files

Copy-Item '..\mcw-continuous-delivery-in-azure-devops\Hands-on lab\lab-files\*' -Destination ./ -Recurse

Sleep 5
$path = "C:\Workspaces\lab\mcw-continuous-delivery-lab-files\infrastructure"
(Get-Content -Path "$path\deploy-webapp.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\deploy-webapp.ps1"
(Get-Content -Path "$path\configure-webapp.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\configure-webapp.ps1"
(Get-Content -Path "$path\deploy-appinsights.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\deploy-appinsights.ps1"
(Get-Content -Path "$path\deploy-infrastructure.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\deploy-infrastructure.ps1"
(Get-Content -Path "$path\seed-cosmosdb.ps1") | ForEach-Object {$_ -Replace "deploymentidvalue", "$DeploymentID"} | Set-Content -Path "$path\seed-cosmosdb.ps1"

Unregister-ScheduledTask -TaskName "Installdocker" -Confirm:$false 
Restart-Computer -Force 
