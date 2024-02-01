#!/bin/bash
yum install -y ansible git
git clone https://github.com/prasenjitroy032/demo-project.git /tmp/ansible-repo
echo '[localhost]' > /etc/ansible/hosts
echo 'localhost ansible_connection=local' >> /etc/ansible/hosts
ansible-playbook  /tmp/ansible-repo/ansible_httpd.yml