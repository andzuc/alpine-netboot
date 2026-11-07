#!/bin/sh
set -x
. ansible-ee/bin/activate
cd ansible
export ANSIBLE_CONFIG=config/ansible.cfg
bin/provision
