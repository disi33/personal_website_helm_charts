Install-Module powershell-yaml
Import-Module powershell-yaml

minikube update-context
./Install-HelmCharts.ps1

$caCert = [System.Convert]::ToBase64String((Get-Content -Path "$HOME/.minikube/ca.crt" -Encoding Byte))
$clientCert = [System.Convert]::ToBase64String((Get-Content -Path "$HOME/.minikube/client.crt" -Encoding Byte))
$clientKey = [System.Convert]::ToBase64String((Get-Content -Path "$HOME/.minikube/client.key" -Encoding Byte))

$kubeYaml = Get-Content -Path "$HOME/.kube/config"
$content = ""
foreach ($line in $kubeYaml) { $content = $content + "`n" + $line }
$yaml = ConvertFrom-YAML $content

$cluster = $yaml.clusters | Where-Object -Property name -eq -Value "minikube"
$cluster.cluster.'certificate-authority-data' = $caCert
$cluster.cluster.Remove('certificate-authority')
$cluster.cluster.server = "https://diesenreiter.com:8443"

$user = $yaml.users | Where-Object -Property name -eq -Value "minikube"
$user.user.'client-certificate-data' = $clientCert
$user.user.'client-key-data' = $clientKey
$user.user.Remove('client-certificate')
$user.user.Remove('client-key')

$output = ConvertTo-Yaml $yaml

Set-Content -Path "$HOME/.kube/config" -Value $output
Write-Host $output