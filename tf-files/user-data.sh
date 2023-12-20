#! /bin/bash


dnf update -y
dnf install python3 -y
pip3 install flask
pip3 install flask_mysql
dnf install git -y
TOKEN="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"
cd /Terraform-Phonebook-Application-deployed-on-AWS/ && git clone  https://$TOKEN@github.com/fhalearslnn/Terraform-Phonebook-Application-deployed-on-AWS.git
# python3 /home/ec2-user/phonebook/phonebook-app.py
python3 /devops-projects/Terraform-Phonebook-Application-deployed-on-AWS/phonebook-app.py
#C:/Users/halea/OneDrive/Masaüstü/devops-projects/Terraform-Phonebook-Application-deployed-on-AWS/