#!/bin/bash
yum install -y httpd
sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
systemctl restart httpd
systemctl enable httpd

