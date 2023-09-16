#!/bin/bash

set -e

if [ -z "$PR_NUMBER" ]; then
  echo >&2 "::error::Required env var PR_NUMBER is missing."
  exit 1
fi

labels=$(gh pr view "$PR_NUMBER" --json labels --jq '.labels[] | .name')
category=$(echo "$labels" | grep -Ee '^release/(major|minor|patch|none)$' || echo -n "")

if [ -z "$category" ]; then
  echo >&2 "::error::Version category label is required. Please add one of the following labels to Pull Request ${PR_NUMBER}: release/major, release/minor, release/patch, release/none"
  exit 1
fi

if [ $(echo "$category" | wc -l) -gt 1 ]; then
  echo >&2 "::error::Only 1 version category label [release/major, release/minor, release/patch, release/none] is allowed on a Pull Request."
  exit 1
fi

if [[ -n "$GITHUB_OUTPUT" ]]; then
  echo "category=$(basename "$category")" >> "$GITHUB_OUTPUT"
fi
