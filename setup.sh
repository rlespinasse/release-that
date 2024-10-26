#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

echo "Create package.json file"
echo '{"description": "","private": true,"version": "0.0.0","release":{}}' >package.json
# shellcheck disable=SC2094
cat <<<"$(jq --arg name "${REPOSITORY_NAME}" '. += {name: $name}' package.json)" >package.json

if [ "${INPUT_DRYRUN}" == "true" ]; then
  if [ -n "${REF_POINT}" ]; then
    echo "  - Setup current branch as releasable (dry-run mode)"
    # shellcheck disable=SC2094
    cat <<<"$(jq --arg branch "${REF_POINT}" '.release += {branches: [$branch]}' package.json)" >package.json
  else
    echo "    Fallback to releasable branches since not current branch is found (dry-run mode)"
    cat <<<"$(jq --argjson branches "$(<"${GITHUB_ACTION_PATH}"/branches.json)" '.release += {branches: $branches}' package.json)" >package.json
  fi
else
  echo "  - Setup releasable branches"
  # shellcheck disable=SC2094
  cat <<<"$(jq --argjson branches "$(<"${GITHUB_ACTION_PATH}"/branches.json)" '.release += {branches: $branches}' package.json)" >package.json
fi

if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
  echo "  - Remove prefix from released version"
  # shellcheck disable=SC2094
  cat <<<"$(jq '.release += {tagFormat: "${version}"}' package.json)" >package.json
fi
