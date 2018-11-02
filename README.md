# AWS-Web-and-EC2-MySQL-db-in-one-terraform-template
AWS Web and EC2 MySQL db in one terraform template

This is an example of a terraform template to create the network infrastructure and nodes for a public facing Web server accessing an EC2 MySQL database in a private subnet.

The main point of this exercise was to prove the template would work before converting the template to use modules.

The cost of this infrastructure is measured in single dollars

The ".txt" files listed may need to be converted using either an editor or dos2unix if the newline format is incorrect.
e.g. using vi, "s/<ctl>V<ctl>M//g" 

Once created the infrastructure can be tested by accessing the web pages:

	http://<Public DNS of the EC2 instance phpapp>
	This will present the Apache web server test page for the host

	http://<Public DNS of the EC2 instance phpapp>/mydb2.php
	This will present the PHP info page for the phpapp EC2 instance

	http://<Public DNS of the EC2 instance phpapp>/mydb.php
	This will present the result of a query against the Mariadb database on the second EC2 instance.
	Please be patient as it can take over 5 minutes for the yum update, patching and database setup to complete before the page is available.
	The page just displays the text "Mycol: MyValues" and nothing else.

For simplicity I have hardcoded certain values but these can obviously be changed to 
secrets, environment variables or entered on the terraform command lines.

	The MySQL db user and password is hardcoded in Dev2Main.tf
	The MySQL db user password is hardcoded in TOPvars.tf 

If you use these scripts please remember to change these values.

The terraform commands to run the scripts are:

	terraform init   -var-file="<location and name of your secrets file>.auto.tfvars"
	terraform apply  -var-file="<location and name of your secrets file>.auto.tfvars"
	terraform delete -var-file="<location and name of your secrets file>.auto.tfvars"

where the contents of the file <location and name of your secrets file>.auto.tfvars is similar to the following:
	#MySecretKeys.auto.tfvars
	access_key = "<your AWS access key"
	secret_key = "<your AWS secret key>"

