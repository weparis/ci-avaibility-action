#!/bin/bash -l
function exportBranchSlug {
  if [ -z ${GITHUB_HEAD_REF} ]; then
    export BRANCH_SLUG=${GITHUB_REF#refs/heads/}
  else
    export BRANCH_SLUG=${GITHUB_HEAD_REF}
  fi
}

function peek {
  if [ -z ${INPUT_INFRA_IDS} ]; then echo "Missing INFRA_IDS. Did you specify 'with' action parameter ?"; fi
  curl -sS -o /dev/null "https://europe-west1-ci-availability.cloudfunctions.net/setInfraForProject?projectName=${GITHUB_REPOSITORY}&infraIds=${INPUT_INFRA_IDS}"
  INFRA_ID=$(curl -sS "https://europe-west1-ci-availability.cloudfunctions.net/peekAvailableInfra?projectName=${GITHUB_REPOSITORY}&branchId=${GITHUB_HEAD_REF}")
  echo "INFRA_ID=$INFRA_ID" >> $GITHUB_ENV
  echo Picked $INFRA_ID
}

function free {
  INFRA_ID=$(curl -sS "https://europe-west1-ci-availability.cloudfunctions.net/peekAvailableInfra?projectName=${GITHUB_REPOSITORY}&branchId=${GITHUB_HEAD_REF}")
  curl -sS "https://europe-west1-ci-availability.cloudfunctions.net/freeInfra?infraId=$INFRA_ID"
}
env

echo BRANCH_SLUG $BRANCH_SLUG
echo INPUT_operation $INPUT_operation
echo INPUT_INFRA_IDS $INPUT_INFRA_IDS

exportBranchSlug

if [ "${INPUT_operation}" == "peek" ]; then
  peek
elif  [ "${INPUT_operation}" == "free" ]; then
  free
else
  echo Unknown or missing operation "${INPUT_operation}"
fi
