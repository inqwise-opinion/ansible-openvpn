#!/bin/bash
while getopts ":e:" option
  do
   case "${option}"
   in
    e) EXTRA=${OPTARG};;
   esac
done

catch_error () {
    echo "An error occurred: $1"
    aws sns publish --topic-arn arn:aws:sns:il-central-1:992382682634:errors --message "$1" --region il-central-1
}

main () {
    set -eEuo pipefail
    #yum install jq -y
    #EXTRA=$(echo "${EXTRA:=\{\}}" |  jq --slurp --compact-output --raw-output 'reduce .[] as $item ({}; . * $item)')
    echo "extra:${EXTRA:=default}"
    pip3.8 install -r requirements.txt
    #export PATH=$PATH:/usr/local/bin
    export ANSIBLE_ROLES_PATH="$(pwd)/ansible-galaxy/roles"
    ansible-galaxy install -p roles -r requirements.yml
    ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 main.yml -e "${EXTRA:=default}"
    #ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 main.yml -e "${EXTRA:=default}" --skip-tags openvpn 
}
trap 'catch_error "$ERROR"' ERR
{ ERROR=$(main 2>&1 1>&$out); } {out}>&1