#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

echo "+ Create package.json file"
echo '{"description": "","private": true,"version": "0.0.0","release":{}}' >package.json
# shellcheck disable=SC2094
cat <<<"$(jq --arg name "${GITHUB_REPOSITORY_NAME_PART}" '. += {name: $name}' package.json)" >package.json

echo "+ Setup releasable branches"
# shellcheck disable=SC2094
cat <<<"$(jq --argjson branches "$(<"${GITHUB_ACTION_PATH}/branches.json")" '.release += {branches: $branches}' package.json)" >package.json

if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
  echo "+ Remove prefix from released version"
  # shellcheck disable=SC2094
  cat <<<"$(jq '.release += {tagFormat: "${version}"}' package.json)" >package.json
fi
