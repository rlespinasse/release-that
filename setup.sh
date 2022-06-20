#!/usr/bin/env bash

if [ -z "$GITHUB_ACTION_PATH" ]; then
  GITHUB_ACTION_PATH=.
fi

setup_dryrun_branch_on_releaserc_json() {
  # shellcheck disable=SC2094
  cat <<<"$(jq --arg branch "${GITHUB_REF_NAME}" '.branches += [$branch]' "$1")" >"$1"
}

setup_dryrun_branch_on_package_json() {
  # shellcheck disable=SC2094
  cat <<<"$(jq --arg branch "${GITHUB_REF_NAME}" '.release.branches += [$branch]' "$1")" >"$1"
}

default_config() {
  echo "+ Create a default .releaserc.json file"
  echo "{\"plugins\": [\"@semantic-release/commit-analyzer\", \"@semantic-release/release-notes-generator\", \"@semantic-release/git\", \"@semantic-release/github\"]}" >.releaserc.json

  if [ "${INPUT_DRYRUN}" == "true" ]; then
    echo "+ Setup current branch as releasable (dry-run mode)"
    setup_dryrun_branch_on_releaserc_json .releaserc.json
  else
    echo "+ Setup releasable branches"
    # shellcheck disable=SC2094
    cat <<<"$(jq --argjson branches "$(<${GITHUB_ACTION_PATH}/default-branches.json)" '.branches = $branches' .releaserc.json)" >.releaserc.json
  fi

  if [ "${INPUT_WITHOUTPREFIX}" == "true" ]; then
    echo "+ Remove prefix from released version"
    # shellcheck disable=SC2094
    cat <<<"$(jq '.tagFormat = "${version}"' .releaserc.json)" >.releaserc.json
  fi

  echo "::set-output name=config_file::.releaserc.json"
  echo "::set-output name=config_file_type::generated"
}

SEMANTIC_RELEASE_CONFIG_FILE=
SEMANTIC_RELEASE_CONFIG_FILE_CONTENT=
if [ -f .releaserc ]; then
  SEMANTIC_RELEASE_CONFIG_FILE=".releaserc"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="json"
fi

if [ -f .releaserc.json ]; then
  SEMANTIC_RELEASE_CONFIG_FILE=".releaserc.json"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="json"
fi

if [ -f .releaserc.yaml ]; then
  SEMANTIC_RELEASE_CONFIG_FILE=".releaserc.yaml"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="yaml"
fi

if [ -f .releaserc.yml ]; then
  SEMANTIC_RELEASE_CONFIG_FILE=".releaserc.yml"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="yaml"
fi

if [ -f .releaserc.js ]; then
  SEMANTIC_RELEASE_CONFIG_FILE=".releaserc.js"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="js"
fi

if [ -f release.config.js ]; then
  SEMANTIC_RELEASE_CONFIG_FILE="release.config.js"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="js"
fi

if [ -f package.json ] && [ "$(jq 'has("release")' package.json)" == "true" ]; then
  SEMANTIC_RELEASE_CONFIG_FILE="package.json"
  SEMANTIC_RELEASE_CONFIG_FILE_CONTENT="package.json"
fi

if [ -n "$SEMANTIC_RELEASE_CONFIG_FILE" ]; then
  echo "+ Found $SEMANTIC_RELEASE_CONFIG_FILE configuration file"
  echo "::set-output name=config_file::${SEMANTIC_RELEASE_CONFIG_FILE}"
  echo "::set-output name=config_file_type::present"
  if [ "${INPUT_DRYRUN}" == "true" ]; then
    echo "+ Setup current branch as releasable (dry-run mode)"
    if [ "${SEMANTIC_RELEASE_CONFIG_FILE_CONTENT}" == "json" ]; then
      setup_dryrun_branch_on_releaserc_json "${SEMANTIC_RELEASE_CONFIG_FILE}"
    fi
    if [ "${SEMANTIC_RELEASE_CONFIG_FILE_CONTENT}" == "package.json" ]; then
      setup_dryrun_branch_on_package_json "${SEMANTIC_RELEASE_CONFIG_FILE}"
    fi
  fi
else
  default_config
fi
