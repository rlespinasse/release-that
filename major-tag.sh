#!/usr/bin/env bash

if [ "${MAJOR_TAG_MAJORTAG}" == "false" ]; then
  echo "Major Tag publication disabled, skipping it."
  if [ -f "$GITHUB_OUTPUT" ]; then
    echo "major_tag_published=false" >>"$GITHUB_OUTPUT"
  else
    echo "::set-output name=major_tag_published::false"
  fi
  exit 0
fi

if [ "${MAJOR_TAG_NEW_RELEASE_PUBLISHED}" == "false" ]; then
  echo "No MAJOR_TAG_NEW release published, skipping major tag publication."
  if [ -f "$GITHUB_OUTPUT" ]; then
    echo "major_tag_published=false" >>"$GITHUB_OUTPUT"
  else
    echo "::set-output name=major_tag_published::false"
  fi
  exit 0
fi

if [ "${MAJOR_TAG_MAJORTAG}" == "auto" ]; then
  echo "Check conditions to publish major Tag (auto mode):"
  if [ -s "action.yml" ] || [ -s "action.yaml" ]; then
    echo "It's a GitHub Action."
  else
    echo "No conditions met, skipping major tag publication."
    if [ -f "$GITHUB_OUTPUT" ]; then
      echo "major_tag_published=false" >>"$GITHUB_OUTPUT"
    else
      echo "::set-output name=major_tag_published::false"
    fi
    exit 0
  fi
fi

echo "Publication of v${MAJOR_TAG_NEW_RELEASE_MAJOR_VERSION} based on ${MAJOR_TAG_NEW_RELEASE_GIT_TAG}"
if [ -f "$GITHUB_OUTPUT" ]; then
  echo "major_tag=v${MAJOR_TAG_NEW_RELEASE_MAJOR_VERSION}" >>"$GITHUB_OUTPUT"
else
  echo "::set-output name=major_tag::v${MAJOR_TAG_NEW_RELEASE_MAJOR_VERSION}"
fi

if [ "${MAJOR_TAG_DRYRUN}" == "false" ]; then
  git push origin "${MAJOR_TAG_NEW_RELEASE_GIT_TAG}:v${MAJOR_TAG_NEW_RELEASE_MAJOR_VERSION}" --force || {
    if [ -f "$GITHUB_OUTPUT" ]; then
      echo "major_tag_published=false" >>"$GITHUB_OUTPUT"
    else
      echo "::set-output name=major_tag_published::false"
    fi
    exit 1
  }
fi

if [ -f "$GITHUB_OUTPUT" ]; then
  echo "major_tag_published=true" >>"$GITHUB_OUTPUT"
else
  echo "::set-output name=major_tag_published::true"
fi
