#!/usr/bin/env bash

export AWS_PROFILE="${AWS_PROFILE:-identity}"

function add-new-key-to-credentials() {
  local dst="${1?}"
  {
    sed "s/\[identity\]/[identity-archived-on-$(gdate +%Y-%m-%d)]/" ~/.aws/credentials
    echo
    echo '[identity]'
    jq -r '.AccessKey | (
    "# as of \(.CreateDate)",
    "aws_access_key_id = \(.AccessKeyId)",
    "aws_secret_access_key = \(.SecretAccessKey)"
    )'
  } >"$dst"
}

function regenerate-credentials-file() {
  local dst="${1?}"
  aws --profile=identity iam create-access-key \
    | tee >(add-new-key-to-credentials "$dst") \
    | jqo
}

keys="$(aws iam list-access-keys | jq '.AccessKeyMetadata|map(select(.Status == "Active"))')" || {
  echo >&2 "unable to use iam; is envvar AWS_PROFILE=${AWS_PROFILE} correct?"
  exit 1
}
num_keys="$(jq length <<<"$keys")"
if [[ "$num_keys" -ne 1 ]] ; then
  echo >&2 "Too many keys: ${num_keys} (expected at most 1)"
  echo >&2 "Consider deleting one via aws --profile=${AWS_PROFILE} iam delete-access-key --access-key-id <id>"
  jq . >&2 <<<"$keys"
  exit 1
fi

dir="$(mktemp -d)"

cp -v ~/.aws/credentials{,.bak-"$(gdate -u --iso=s)"}

set -o pipefail

new_key="$(regenerate-credentials-file "$dir"/credentials)" && {
  cp -v {"${dir}",~/.aws}/credentials
  echo "deactivating existing key"
  echo "Now remember to restart finto"
}
