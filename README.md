# apache2
frist step is write an terraform module for ec2 instance and install an ansible in terraform
write an ansible plybook file to install an source code appache2
id_rsa is the private key which we needed to access the newly created ec2 instance same key is being utilized by ansable module to connect and install
apache.yml file is used for installing apache2 using package where as apache_source.yml is used for source code installation.
Based on our need we can change the requried file in main.tf file

after cloning the repo we need to initilazige terraform module bu using terraform init
then we need to run terraform plan command after checking if everything is fine we need to rum terraform apply command
Pre Requiests,
You should be loging into aws using aws cli before running terraform module
You should be having terraform and ansable installed in your machine.
