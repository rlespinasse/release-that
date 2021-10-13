#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

echo "+ Create package.json file"
echo '{"description": "","private": true,"version": "0.0.0","release":{}}' >package.json
# shellcheck disable=SC2094
cat <<<"$(jq --arg name "${GITHUB_REPOSITORY_NAME_PART}" '. += {name: $name}' package.json)" >package.json

if [ "${INPUT_DRYRUN}" == "true" ]; then
  echo "+ Setup current branch as releasable (dry-run mode)"
  # shellcheck disable=SC2094
  cat <<<"$(jq --arg branch "${GITHUB_REF_NAME}" '.release += {branches: [$branch]}' package.json)" >package.json
else
  echo "+ Setup releasable branches"
  # shellcheck disable=SC2094
  cat <<<"$(jq --argjson branches "$(<${GITHUB_ACTION_PATH}/branches.json)" '.release += {branches: $branches}' package.json)" >package.json
fi

if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
  echo "+ Remove prefix from released version"
  # shellcheck disable=SC2094
  cat <<<"$(jq '.release += {tagFormat: "${version}"}' package.json)" >package.json
fi
