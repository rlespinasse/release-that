#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

PACKAGE_CONFIG_PATH=.
PACKAGE_NAME="${GITHUB_REPOSITORY_NAME_PART}"
if [ -n "$INPUT_WORKINGDIRECTORY" ]; then
  PACKAGE_CONFIG_PATH="$INPUT_WORKINGDIRECTORY"
  PACKAGE_NAME="$INPUT_WORKINGDIRECTORYSLUG"
  echo "extends-config=semantic-release-monorepo" >>"$GITHUB_OUTPUT"
fi

TAG_FORMAT="v\${version}"
if [ -n "$INPUT_WORKINGDIRECTORY" ]; then
  if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
    TAG_FORMAT="${INPUT_WORKINGDIRECTORYSLUG}-\${version}"
  else
    TAG_FORMAT="${INPUT_WORKINGDIRECTORYSLUG}-v\${version}"
  fi
elif [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
  TAG_FORMAT="\${version}"
fi

echo "+ Create package.json file"
cat <<EOF >"$PACKAGE_CONFIG_PATH/package.json"
{
  "name": "${PACKAGE_NAME}",
  "description": "",
  "private": true,
  "version": "0.0.0",
  "engines": {
    "node": ">=20.0.0"
  },
  "release": {
    "tagFormat": "${TAG_FORMAT}"
  }
}
EOF

if [ "${INPUT_DRYRUN}" == "true" ]; then
  echo "+ Setup current branch as releasable (dry-run mode)"
  # shellcheck disable=SC2094
  cat <<<"$(jq --arg branch "${GITHUB_REF_NAME}" '.release += {branches: [$branch]}' "$PACKAGE_CONFIG_PATH/package.json")" >"$PACKAGE_CONFIG_PATH/package.json"
else
  echo "+ Setup releasable branches"
  # shellcheck disable=SC2094
  cat <<<"$(jq --argjson branches "$(<"${GITHUB_ACTION_PATH}/branches.json")" '.release += {branches: $branches}' "$PACKAGE_CONFIG_PATH/package.json")" >"$PACKAGE_CONFIG_PATH/package.json"
fi
