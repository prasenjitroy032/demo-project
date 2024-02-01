#!/bin/bash
yum install -y git
pip3 install ansible
git clone https://github.com/prasenjitroy032/demo-project.git /tmp/ansible-repo
mkdir -p  /etc/ansible
touch /etc/ansible/hosts
echo '[localhost]' > /etc/ansible/hosts
echo 'localhost ansible_connection=local' >> /etc/ansible/hosts
ansible-playbook  -i /etc/ansible/hosts /tmp/ansible-repo/ansible_httpd.yml