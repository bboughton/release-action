#!/bin/bash

set -e

category=$1
prefix=$2
if [ -z "$prefix" ]; then
  tag=$(git tag --list --sort=-v:refname "*" | head -n1)
else
  tag=$(git tag --list --sort=-v:refname "${prefix}/*" | head -n1)
fi

if ! echo "$category" | grep -Ee '^(major|minor|patch)$' >/dev/null; then
  echo >&2 "::error::Invalid version category: $category"
  exit 1
fi

major=$(echo "$tag" | sed -e "s|v||" | cut -d '.' -f 1)
minor=$(echo "$tag" | sed -e "s|v||" | cut -d '.' -f 2)
patch=$(echo "$tag" | sed -e "s|v||" | cut -d '.' -f 3)

case $category in
  "major" )
    major=$(( ${major} +1 ))
    minor=0
    patch=0
    ;;
  "minor" )
    minor=$(( ${minor} +1 ))
    patch=0
    ;;
  "patch" )
    patch=$(( ${patch} +1 ))
    ;;
esac

if [ -z "$prefix" ]; then
  new_version="v${major:-0}.${minor:-0}.${patch:-0}"
else
  new_version="${prefix}/v${major:-0}.${minor:-0}.${patch:-0}"
fi

if [ -z "$tag" ]; then
  gh release create "$new_version" --notes ""
else
  gh release create "$new_version" --generate-notes --notes-start-tag "$tag"
fi

if [[ -n "$GITHUB_OUTPUT" ]]; then
  echo "tag=$new_version" >> "$GITHUB_OUTPUT"
fi
