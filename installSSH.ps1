<powershell>
# Install openssh
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Write-Host "Adding public key from instance metadata to authorized_keys"
$keyPath = "C:\ProgramData\ssh\administrators_authorized_keys"
$keyUrl = "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key"

$ErrorActionPreference = 'SilentlyContinue'
Do {
	Start-Sleep 1
	Invoke-WebRequest $keyUrl -UseBasicParsing -OutFile $keyPath
} While ( -Not (Test-Path $keyPath) )
$ErrorActionPreference = 'Stop'

# Fix permissions on administrators_autorized_keys file
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl

# Set ssh to automatic startup
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic

# Start ssh agent
Start-Service sshd
Start-Service ssh-agent

Write-Host "Opening firewall port 22"
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

# Change default shell to powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
</powershell>
