#!/usr/bin/env bash

CURRENT_DIR=${PWD}
TMP_DIR=/tmp/ansible-test
mkdir -p $TMP_DIR 2> /dev/null

# Create hosts inventory
cat << EOF > $TMP_DIR/hosts
[webservers]
localhost ansible_connection=local
EOF

# Create group_vars for the webservers
mkdir -p $TMP_DIR/group_vars 2> /dev/null
cat << EOF > $TMP_DIR/group_vars/webservers

drupal_drush_user: drush
drupal_sites:
  - site_name: drupal-demo
    site_domain: drupal-demo.local
    site_path: /var/www/drupal-demo
    site_access_log_path: "/var/www/drupal-demo/drupal-demo.access.log"
    site_error_log_path: "/var/www/drupal-demo/drupal-demo.error.log"

EOF

# Create Ansible config
cat << EOF > $TMP_DIR/ansible.cfg
[defaults]
roles_path = $CURRENT_DIR/../
host_key_checking = False
EOF

# Create playbook.yml
cat << EOF > $TMP_DIR/playbook.yml
---

- hosts: webservers
  gather_facts: yes
  sudo: yes

  roles:
    - ansible-drupal
EOF

export ANSIBLE_CONFIG=$TMP_DIR/ansible.cfg

# Syntax check
ansible-playbook $TMP_DIR/playbook.yml -i $TMP_DIR/hosts --syntax-check

# First run
ansible-playbook $TMP_DIR/playbook.yml -i $TMP_DIR/hosts

# Idempotence test
# ansible-playbook $TMP_DIR/playbook.yml -i $TMP_DIR/hosts | grep -q 'changed=1.*failed=0' \
# 	&& (echo 'Idempotence test: pass' && exit 0) \
# 	|| (echo 'Idempotence test: fail' && exit 1)

