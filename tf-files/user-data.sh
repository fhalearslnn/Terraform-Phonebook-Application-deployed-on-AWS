#! /bin/bash


dnf update -y
dnf install python3 -y
pip3 install flask
pip3 install flask_mysql
dnf install git -y
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxx" #write here your token
cd /Terraform-Phonebook-Application-deployed-on-AWS/ && git clone  https://$TOKEN@github.com/fhalearslnn/Terraform-Phonebook-Application-deployed-on-AWS.git
# python3 /home/ec2-user/phonebook/phonebook-app.py
python3 /devops-projects/Terraform-Phonebook-Application-deployed-on-AWS/phonebook-app.py

