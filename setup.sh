#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

CONFIG_PATH=.
if [ -n "$INPUT_WORKINGDIRECTORY" ]; then
  CONFIG_PATH="$INPUT_WORKINGDIRECTORY"
  echo "extends-config=semantic-release-monorepo" >>"$GITHUB_OUTPUT"
fi

echo "+ Create package.json file"
echo '{"description": "","private": true,"version": "0.0.0","release":{}}' >"$CONFIG_PATH/package.json"
# shellcheck disable=SC2094
cat <<<"$(jq --arg name "${GITHUB_REPOSITORY_NAME_PART}" '. += {name: $name}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"

if [ "${INPUT_DRYRUN}" == "true" ]; then
  echo "+ Setup current branch as releasable (dry-run mode)"
  # shellcheck disable=SC2094
  cat <<<"$(jq --arg branch "${GITHUB_REF_NAME}" '.release += {branches: [$branch]}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"
else
  echo "+ Setup releasable branches"
  # shellcheck disable=SC2094
  cat <<<"$(jq --argjson branches "$(<"${GITHUB_ACTION_PATH}/branches.json")" '.release += {branches: $branches}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"
fi

if [ -n "$INPUT_WORKINGDIRECTORY" ]; then
  echo "+ Setup prefix from released version using working-directory input"
  if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
    # shellcheck disable=SC2094
    cat <<<"$(jq '.release += {tagFormat: "'"${INPUT_WORKINGDIRECTORYSLUG}"'-${version}"}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"
  else
    # shellcheck disable=SC2094
    cat <<<"$(jq '.release += {tagFormat: "'"${INPUT_WORKINGDIRECTORYSLUG}"'-v${version}"}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"
  fi
elif [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
  echo "+ Remove prefix from released version"
  # shellcheck disable=SC2094
  cat <<<"$(jq '.release += {tagFormat: "${version}"}' "$CONFIG_PATH/package.json")" >"$CONFIG_PATH/package.json"
fi
