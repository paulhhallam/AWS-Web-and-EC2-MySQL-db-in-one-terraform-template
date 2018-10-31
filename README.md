# AWS-Web-and-EC2-MySQL-db-in-one-terraform-template
AWS Web and EC2 MySQL db in one terraform template

This is an example of a terraform template to create the network infrastructure and nodes for a 
Public Web server accessing a private EC2 MySQL database.

The main point of this exercise was to prove the template would work before converting the template to use modules.

The cost of this infrastructure is measured in single dollars, especially when almost immediately destroyed:

For simplicity I have hardcoded certain values but these can obviously be changed to secrets, 
environment variables or entered on the terraform command lines.

	The MySQL db user and password is hardcoded in Dev2Main.tf
	The MySQL db user password is hardcoded in TOPvars.tf 

If you use these scripts please remember to change these values.

The terraform commands to run the scripts are:

	terraform init -var-file="<location and name of your secrets file>.auto.tfvars"
	terraform apply -var-file="<location and name of your secrets file>.auto.tfvars"
	terraform delete -var-file="<location and name of your secrets file>.auto.tfvars"

where <location and name of your secrets file>.auto.tfvars is similar to the following:

	#MySecretKeys.auto.tfvars
	access_key = "<your AWS access key"
	secret_key = "<your AWS secret key>"
