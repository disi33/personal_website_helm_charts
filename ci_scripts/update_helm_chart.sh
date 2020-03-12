#!/bin/bash

HELM_CHART="website"

VERSION_NUMBER=$1

git clone https://github.com/disi33/personal_website_helm_charts /tmp/helm_charts
pushd /tmp/helm_charts/$HELM_CHART/
sed -i 's/[0-9]\+\.[0-9]\+\.[0-9]\+/'"$VERSION_NUMBER"'/g' /tmp/helm_charts/$HELM_CHART/values-imgtag.yaml
sed -i 's/[0-9]\+\.[0-9]\+\.[0-9]\+/'"$VERSION_NUMBER"'/g' /tmp/helm_charts/$HELM_CHART/Chart.yaml
git add /tmp/helm_charts/$HELM_CHART/values-imgtag.yaml
git add /tmp/helm_charts/$HELM_CHART/Chart.yaml
git commit -m "[auto] bump $HELM_CHART chart version number to $VERSION_NUMBER"
git config remote.origin.url https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/disi33/personal_website_helm_charts
git push origin master
popd

exit 0