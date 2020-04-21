# minikube start --apiserver-names=diesenreiter.com

$directoryNames = Get-ChildItem -Path . -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name
$helmCharts = $directoryNames | Where-Object -Property Name -NotLike ".*"
$extraCharts = @("helm")

. helm repo add stable https://kubernetes-charts.storage.googleapis.com
. helm repo add multi-juicer https://iteratec.github.io/multi-juicer/
. helm repo update

if (!$IsLinux)
{
    netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=8443 connectaddress=192.168.1.123 connectport=8443
    netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=80 connectaddress=192.168.1.123 connectport=80
    netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=443 connectaddress=192.168.1.123 connectport=443
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=80 connectaddress=192.168.1.123 connectport=80
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=443 connectaddress=192.168.1.123 connectport=443
    netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=30000 connectaddress=192.168.1.123 connectport=30000
    netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=30001 connectaddress=192.168.1.123 connectport=30001
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=30000 connectaddress=192.168.1.123 connectport=30000
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=30001 connectaddress=192.168.1.123 connectport=30001
    netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=8443 connectaddress=192.168.1.123 connectport=8443
    #netsh interface portproxy add v4tov4 listenaddress=diesenreiter.com listenport=80 connectaddress=192.168.1.123 connectport=80
    #netsh interface portproxy add v4tov4 listenaddress=diesenreiter.com listenport=8443 connectaddress=192.168.1.123 connectport=8443
    #netsh interface portproxy add v4tov4 listenaddress=diesenreiter.com listenport=8443 connectaddress=127.0.0.1 connectport=8443 protocol=tcp
    #netsh interface portproxy add v4tov4 listenaddress=diesenreiter.com listenport=80 connectaddress=127.0.0.1 connectport=80 protocol=tcp
}

git checkout master
git pull origin master --rebase

# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.yaml

foreach($chart in $helmCharts)
{
    $chartname = $chart.Name

    helm upgrade --install $chartname ./$chartname --values ./$chartname/values.yaml --values ./$chartname/values-imgtag.yaml
}

foreach($extraChart in $extraCharts)
{
    switch($extraChart)
    {
        "helm" 
        {
            if (!$IsLinux)
            {
                minikube addons enable ingress
            }
        }
    }
}

$PortForwardTemplate = "spec:
  template:
    spec:
      containers:
      - name: nginx-ingress-controller
        ports:
         - containerPort: {0}
           hostPort: {0}
           protocol: {1}"
$PortRouteTemplate = "data:
  `"{0}`": `"{1}`""

$TcpPorts = Get-Content -Raw -Path $PSScriptRoot/tcp-ports.json | ConvertFrom-json

foreach ($tcpPortProp in $TcpPorts.PSObject.Properties)
{
    $portRoutePatch = $PortRouteTemplate -f $tcpPortProp.Name,$tcpPortProp.Value
    kubectl patch configmap tcp-services -n kube-system --patch "$($portRoutePatch)"
    # $portForwardPatch = $PortForwardTemplate -f $tcpPortProp.Name,"TCP"
    # kubectl patch deployment nginx-ingress-controller --patch "$($portForwardPatch)" -n kube-system
}

$UdpPorts = Get-Content -Raw -Path $PSScriptRoot/udp-ports.json | ConvertFrom-json

foreach ($udpPortProp in $UdpPorts.PSObject.Properties)
{
    $portRoutePatch = $PortRouteTemplate -f $udpPortProp.Name,$udpPortProp.Value
    kubectl patch configmap udp-services -n kube-system --patch "$($portRoutePatch)"
    # $portPatch = $PortForwardTemplate -f $udpPortProp.Name,"UDP"
    # kubectl patch deployment nginx-ingress-controller --patch "$($portPatch)" -n kube-system
}