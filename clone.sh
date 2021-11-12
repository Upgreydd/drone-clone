#!/bin/sh
rm -rf ./*
if [[ -n "$PLUGIN_REMOTE" ]] && [[ -n "$PLUGIN_VERSION" ]] ; then
  git clone --single-branch --branch "${VERSION:-${DRONE_BRANCH}}" https://github.com/"${REMOTE:-${DRONE_REPO_NAMESPACE}}"/"${DRONE_REPO_NAME}".git .
else
  git clone -b "$DRONE_BRANCH" "$DRONE_REMOTE_URL" .
  git checkout "$DRONE_BRANCH"
  git fetch origin "$DRONE_COMMIT_REF"
  git merge "$DRONE_COMMIT"
fi
