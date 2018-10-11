provider "aws" {
  region     = "${var.TOPregion}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_instance" "database" {
  ami           = "${lookup(var.TOPamis, var.TOPregion)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  vpc_security_group_ids = ["${aws_security_group.Database.id}"]
  subnet_id = "${aws_subnet.PrivateAZA.id}"
  key_name = "${var.aws_key_name}"
  tags {
        Name = "database"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y mysql55-server
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE mytable (mycol varchar(255));' test
  mysql -u root -psecret -e "INSERT INTO mytable (mycol) values ('MyValues') ;" test
HEREDOC
}

resource "aws_vpc_dhcp_options" "mydhcp" {
  domain_name = "${var.TOPDnsZoneName}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name = "My internal name"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.mydhcp.id}"
}

/* DNS PART ZONE AND RECORDS */

resource "aws_route53_zone" "main" {
  name    = "${var.TOPDnsZoneName}"
  vpc_id  = "${aws_vpc.DevEc2DbVpc.id}"
  comment = "Managed by ME"
}

resource "aws_route53_record" "database" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "mydatabase.${var.TOPDnsZoneName}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.database.private_ip}"]
}

resource "aws_instance" "webphpapp" {
  ami = "${lookup(var.TOPamis, var.TOPregion)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.FrontEnd.id}"]
  key_name = "${var.aws_key_name}"
  tags {
        Name = "phpapp"
  }

  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd24 php56 php56-mysqlnd
  service httpd start
  chkconfig httpd on
  echo "<?php" >> /var/www/html/calldb.php
  echo "\$conn = new mysqli('database', 'root', 'secret', 'test');" >> /var/www/html/calldb.php
  echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/calldb.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/calldb.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'] ;} " >> /var/www/html/calldb.php
  echo "\$conn->close(); " >> /var/www/html/calldb.php
  echo "?>" >> /var/www/html/calldb.php
HEREDOC
  }

# Declare the data source
data "aws_availability_zones" "available" {}

/* EXTERNAL NETWORK, IG, ROUTE TABLE */
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  tags {
    Name = "internet gw MY generated"
  }
}
resource "aws_network_acl" "all" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  egress {
    protocol = "-1"
    rule_no = 2
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 1
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags {
    Name = "open acl"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  tags {
      Name = "Public"
  }
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  tags {
      Name = "Private"
  }
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.PublicAZA.id}"
  }
}

resource "aws_eip" "forNat" {
    vpc      = true
}

resource "aws_nat_gateway" "PublicAZA" {
  allocation_id = "${aws_eip.forNat.id}"
  subnet_id = "${aws_subnet.PublicAZA.id}"
}

####################################################
#FROM SUBNETS.TF
#
resource "aws_subnet" "PublicAZA" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  cidr_block = "${var.TOPvpcsubn-pub-cidr}"
  tags {
        Name = "PublicAZA"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "PrivateAZA" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  cidr_block = "${var.TOPvpcsubn-pri-cidr}"
  tags {
        Name = "PublicAZB"
  }
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

#
#
resource "aws_route_table_association" "PublicAZA" {
    subnet_id = "${aws_subnet.PublicAZA.id}"
    route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "PrivateAZA" {
    subnet_id = "${aws_subnet.PrivateAZA.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "FrontEnd" {
  name = "FrontEnd"
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  description = "ONLY HTTP CONNECTION INBOUND"
  tags {
    Name = "FrontEnd"
	}
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
	}
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "Database" {
  name = "Database"
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  description = "ONLY tcp CONNECTION INBOUND"
  tags {
    Name = "Database"
	}
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    security_groups = ["${aws_security_group.FrontEnd.id}"]
	}
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
#
resource "aws_vpc" "DevEc2DbVpc" {
  cidr_block = "${var.TOPvpc-cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "DevEc2DbVpc"
  }
}
