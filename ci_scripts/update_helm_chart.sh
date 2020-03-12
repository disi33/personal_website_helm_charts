#!/bin/bash

HELM_CHART="website"

VERSION_NUMBER=$1

git clone https://github.com/disi33/personal_website_helm_charts /tmp/helm_charts &> /dev/null
pushd /tmp/helm_charts/personal_website_helm_charts/$HELM_CHART/
sed -i 's/tag: .*/tag: $VERSION_NUMBER/g' /tmp/helm_charts/personal_website_helm_charts/$HELM_CHART/values-imgtag.yaml
sed -i 's/version: .*/version: $VERSION_NUMBER/g' /tmp/helm_charts/personal_website_helm_charts/$HELM_CHART/Chart.yaml
git add /tmp/helm_charts/personal_website_helm_charts/$HELM_CHART/values-imgtag.yaml
git commit -m "[auto] bump $HELM_CHART chart version number to $VERSION_NUMBER"
git push origin master
popd

exit 0