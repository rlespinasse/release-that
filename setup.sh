#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

PACKAGE_CONFIG_PATH=.
PACKAGE_NAME="${SETUP_REPOSITORY_NAME}"
if [ -n "$SETUP_WORKINGDIRECTORY" ]; then
  PACKAGE_CONFIG_PATH="$SETUP_WORKINGDIRECTORY"
  PACKAGE_NAME="$SETUP_WORKINGDIRECTORYSLUG"
fi

TAG_FORMAT="v\${version}"
if [ -n "$SETUP_WORKINGDIRECTORY" ]; then
  if [ "${SETUP_WITHOUTPREFIX}" == "true" ]; then
    TAG_FORMAT="${SETUP_WORKINGDIRECTORYSLUG}-\${version}"
  else
    TAG_FORMAT="${SETUP_WORKINGDIRECTORYSLUG}-v\${version}"
  fi
elif [ "${SETUP_WITHOUTPREFIX}" == "true" ]; then
  TAG_FORMAT="\${version}"
fi

echo "::group::Create package.json file"
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

inject_current_branch() {
  jq --arg branch "${SETUP_GITHUB_REF_POINT}" \
    '.release += {branches: [$branch]}' \
    "${PACKAGE_CONFIG_PATH}/package.json" >"${PACKAGE_CONFIG_PATH}/package.json.tmp" &&
    mv "${PACKAGE_CONFIG_PATH}/package.json.tmp" "${PACKAGE_CONFIG_PATH}/package.json"
}

inject_releasable_branches() {
  jq --argjson branches "$(cat "${GITHUB_ACTION_PATH}/branches.json")" \
    '.release += {branches: $branches}' \
    "${PACKAGE_CONFIG_PATH}/package.json" >"${PACKAGE_CONFIG_PATH}/package.json.tmp" &&
    mv "${PACKAGE_CONFIG_PATH}/package.json.tmp" "${PACKAGE_CONFIG_PATH}/package.json"
}

if [ "${SETUP_DRYRUN}" == "true" ]; then
  if [ -n "${SETUP_GITHUB_REF_POINT}" ]; then
    echo "\ Setup current branch as releasable (dry-run mode)"
    inject_current_branch
  else
    echo "\ Fallback to releasable branches since not current branch is found (dry-run mode)"
    inject_releasable_branches
  fi
else
  echo "\ Setup releasable branches"
  inject_releasable_branches
fi
echo "::endgroup::"

if [ -n "$SETUP_WORKINGDIRECTORY" ]; then
  echo "::group::Setup monorepo support"
  echo "extends-config=semantic-release-monorepo" >>"$GITHUB_OUTPUT"
  npm install -D semantic-release-monorepo
  echo "::endgroup::"
fi
