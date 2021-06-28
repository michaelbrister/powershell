<powershell>
$Document=(invoke-restmethod -uri http://169.254.169.254/latest/dynamic/instance-identity/document)
New-SSMAssociation -InstanceId $Document.instanceid -Region $Document.region -Name domain-join
Restart-Computer -Force
</powershell>
