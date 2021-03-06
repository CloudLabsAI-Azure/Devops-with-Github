Param (
   
    [string]
    $DeploymentID
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
$adminUsername = "demouser"
[System.Environment]::SetEnvironmentVariable('DeploymentID', $DeploymentID,[System.EnvironmentVariableTarget]::Machine)


Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Sleep 10
refreshenv

choco install vscode -y
choco install dotnetcore-sdk -y
choco install azure-functions-core-tools -y
choco install azure-cli -y

sleep 10

#Install synapse modules
Install-PackageProvider NuGet -Force

#installing extensions to vscode
code --install-extension ms-dotnettools.csharp 
code --install-extension vsciot-vscode.azure-iot-tools
code --install-extension ms-azuretools.vscode-azurefunctions

sleep  10

#Assign Packages to Install
choco install git -y
choco install nodejs.install -y

sleep 5


$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Devops-with-Github/main/template/logontask.ps1","C:\Packages\logontask.ps1")


#Enable Autologon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String  
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "Password.1!!" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord


# Scheduled Task to Run PostConfig.ps1 screen on logon
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\demouser" 
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\Packages\logontask.ps1"
Register-ScheduledTask -TaskName "Installdocker" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force




Stop-Transcript
Restart-Computer -Force 
