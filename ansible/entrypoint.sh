#!/bin/sh
. ansible-ee/bin/activate
cd ansible
export ANSIBLE_CONFIG=config/ansible.cfg
bin/provision
