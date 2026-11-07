#!/bin/sh
. ansible-ee/bin/activate
cd ansible
export ANSIBLE_CONFIG=config/vagrant/ansible.cfg
bin/provision ${ANSIBLE_ARGS}
