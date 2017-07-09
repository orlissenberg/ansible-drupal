#!/usr/bin/env bash

CURRENT_DIR=${PWD}
TMP_DIR=/tmp/ansible-test
mkdir -p ${TMP_DIR} 2> /dev/null

# Create hosts inventory
cat << EOF > ${TMP_DIR}/hosts
[webservers]
localhost ansible_connection=local
EOF

# Create group_vars for the web servers
mkdir -p ${TMP_DIR}/group_vars 2> /dev/null
cat << EOF > ${TMP_DIR}/group_vars/webservers

# drupal_mysql_admin_user: root
# drupal_mysql_admin_password: i_am_root

drupal_composer_tasks: false
drupal_console_tasks: false
drupal_drush_tasks: false

drupal_drush_users:
  - drupal
  - root

drupal_sites:
  - site_owner: debian
    site_group: www-data
    site_name: drupal-demo
    site_domain: drupal-demo.dev
    site_path: /var/www/drupal-demo
    site_access_log_path: "/var/www/drupal-demo/drupal-demo.access.log"
    site_error_log_path: "/var/www/drupal-demo/drupal-demo.error.log"
    site_account_name: admin
    site_account_pass: pass
    site_account_mail: admin@drupal-demo.local
    mysql_database_name: drupal_demo
    mysql_user_name: demouser
    mysql_user_password: demopass

EOF

# Create Ansible config
cat << EOF > ${TMP_DIR}/ansible.cfg
[defaults]
roles_path = ${CURRENT_DIR}/../
host_key_checking = False
EOF

# Create playbook.yml
cat << EOF > ${TMP_DIR}/playbook.yml
---

- hosts: webservers
  gather_facts: yes
  become: yes

  roles:
    - ansible-drupal

#  vars_prompt:
#    - name: "drupal_github_oauth"
#      prompt: "Enter GitHub OAuth"
#      when: drupal_github_oauth == false


EOF

export ANSIBLE_CONFIG=${TMP_DIR}/ansible.cfg

# Syntax check
ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts --syntax-check

# First run
ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts

# Idempotence test
# ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts | grep -q 'changed=1.*failed=0' \
#   && (echo 'Idempotence test: pass' && exit 0) \
#   || (echo 'Idempotence test: fail' && exit 1)

