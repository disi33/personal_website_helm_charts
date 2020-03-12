#!/bin/bash

export SEMVER_LAST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null)
export LAST_COMMIT_MESSAGE=$(git log --oneline -1 --pretty=%B)

if [[ $LAST_COMMIT_MESSAGE =~ ^\[.*\].* ]]; then
    export SEMVER_RELEASE_LEVEL=$(git log --oneline -1 --pretty=%B | cat | tr -d '\n' | cut -d "[" -f2 | cut -d "]" -f1)
else
    export SEMVER_RELEASE_LEVEL="patch"
fi

if [ -z $SEMVER_LAST_TAG ]; then
    #>&2 echo "No tags defined"
    SEMVER_LAST_TAG="0.0.1"
fi

git clone https://github.com/fsaintjacques/semver-tool /tmp/semver &> /dev/null
SEMVER_NEW_TAG=$(/tmp/semver/src/semver bump $SEMVER_RELEASE_LEVEL $SEMVER_LAST_TAG)
git tag $SEMVER_NEW_TAG &> /dev/null
git push origin --tags &> /dev/null
echo $SEMVER_NEW_TAG

exit 0