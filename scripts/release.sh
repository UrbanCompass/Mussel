#!/bin/sh

publish=$1
spec="Mussel.podspec"
template="$spec.template"

#replace spec tag
export MusselVersion=`git describe --tags --abbrev=0`
./scripts/template.sh Mussel.podspec.template $spec

echo "Updating spec.. ✅"
cat $spec

if [ "$publish" == "publish" ]; then
    pod trunk push $spec
else
    pod lib lint --verbose --allow-warnings
fi
