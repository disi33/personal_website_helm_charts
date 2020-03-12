$directoryNames = Get-ChildItem -Path . -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name
$helmCharts = $directoryNames | Where-Object -Property Name -NotLike ".*"

foreach($chart in $helmCharts)
{
    $chartname = $chart.Name

    helm upgrade --install $chartname ./$chartname --values ./$chartname/values.yaml --values ./$chartname/values-imgtag.yaml
}