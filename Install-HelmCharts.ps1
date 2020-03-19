$directoryNames = Get-ChildItem -Path . -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name
$helmCharts = $directoryNames | Where-Object -Property Name -NotLike ".*"
$extraCharts = @("helm")

. helm repo add stable https://kubernetes-charts.storage.googleapis.com
. helm repo update
netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=8443 connectaddress=192.168.1.123 connectport=8443
netsh interface portproxy add v4tov4 listenaddress=192.168.1.118 listenport=80 connectaddress=192.168.1.123 connectport=80
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=80 connectaddress=192.168.1.123 connectport=80
#netsh interface portproxy add v4tov4 listenaddress=diesenreiter.com listenport=80 connectaddress=192.168.1.123 connectport=80
#netsh interface portproxy add v4tov4 listenport=8443 connectaddress=127.0.0.1 connectport=8443 listenaddress=diesenreiter.com protocol=tcp
#netsh interface portproxy add v4tov4 listenport=80 connectaddress=127.0.0.1 connectport=80 listenaddress=diesenreiter.com protocol=tcp

git checkout master
git pull origin master --rebase

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
            minikube addons enable ingress
        }
    }
}