#!/bin/bash
catch_error () {
    echo "An error occurred: $1"
    aws sns publish --topic-arn arn:aws:sns:il-central-1:992382682634:errors --message "$1" --region il-central-1
}
main () {
    set -eEuo pipefail
    pip3.8 install -r requirements.txt --user virtualenv
    export ANSIBLE_ROLES_PATH="$(pwd)/ansible-galaxy/roles"
    ansible-galaxy install -p roles -r requirements.yml
    ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 main.yml --skip-tags message
}
trap 'catch_error "$ERROR"' ERR
{ ERROR=$(main 2>&1 1>&$out); } {out}>&1