#!/usr/bin/env bash

export AWS_PROFILE="${AWS_PROFILE:-identity}"

profiles="$(aws iam list-access-keys)" || {
  echo >&2 "unable to use iam; is envvar AWS_PROFILE=${AWS_PROFILE} correct?"
  exit 1
}
num_profiles="$(jq '.AccessKeyMetadata|length' <<<"$profiles")"
if [[ "$num_profiles" -ne 1 ]] ; then
  echo >&2 "Too many profiles: ${num_profiles} (expected at most 1)"
  echo >&2 "Consider deleting one via aws --profile=${AWS_PROFILE} iam delete-access-key --access-key-id <id>"
  jq . >&2 <<<"$profiles"
  exit 1
fi

dir="$(mktemp -d)"

cp -v ~/.aws/credentials{,.bak-"$(gdate -u --iso=s)"}

set -o pipefail

aws --profile=identity iam create-access-key | {
  sed "s/\[identity\]/[identity-archived-on-$(gdate +%Y-%m-%d)]/" ~/.aws/credentials
  echo
  echo '[identity]'
  jq -r '.AccessKey | ("# as of \(.CreateDate)", "aws_access_key_id = \(.AccessKeyId)", "aws_secret_access_key = \(.SecretAccessKey)")'
} > "${dir}/credentials" && {
  cp -v {"${dir}",~/.aws}/credentials
  echo "Now remember to restart finto"
}
