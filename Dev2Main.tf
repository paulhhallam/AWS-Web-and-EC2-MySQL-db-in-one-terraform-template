#
# Test by going to webhost://mydb.php 
#
provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "database" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  key_name = "${var.key_name}"
  root_block_device {
	  delete_on_termination = true
  }
  tags {
    Name = "database"
	Environment = "${var.environment}"
  }
  user_data = "${file("database.txt")}"
}

resource "aws_instance" "webphpapp" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.FrontEnd.id}"]
  key_name = "${var.key_name}"
  root_block_device {
	  delete_on_termination = true
	  }
  tags {
    Name = "phpapp"
	Environment = "${var.environment}"
  }
  user_data = "${file("webphpapp.txt")}"
}

resource "aws_vpc_dhcp_options" "mydhcp" {
  domain_name = "${var.DnsZoneName}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name = "My internal name"
	Environment = "${var.environment}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.mydhcp.id}"
}

/* DNS PART ZONE AND RECORDS */

resource "aws_route53_zone" "main" {
  name    = "${var.DnsZoneName}"
  vpc_id  = "${aws_vpc.DevEc2DbVpc.id}"
  comment = "Managed by ME"
}

resource "aws_route53_record" "database" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "database.${var.DnsZoneName}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.database.private_ip}"]
}

# Declare the data source
data "aws_availability_zones" "available" {}

/* EXTERNAL NETWORK, IG, ROUTE TABLE */
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  tags {
    Name = "internet gw MY generated"
	Environment = "${var.environment}"
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
	Environment = "${var.environment}"
	}
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  tags {
    Name = "Public"
	Environment = "${var.environment}"
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
	Environment = "${var.environment}"
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
  depends_on = ["aws_internet_gateway.gw"]
  tags {
        Name = "DEVv2"
  }
}

resource "aws_subnet" "PublicAZA" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  cidr_block = "${var.vpcsubn-pub-cidr}"
  tags {
	Name = "PublicAZA"
	Environment = "${var.environment}"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "PrivateAZA" {
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  cidr_block = "${var.vpcsubn-pri-cidr}"
  tags {
    Name = "PublicAZB"
	Environment = "${var.environment}"
  }
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

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
	Environment = "${var.environment}"
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

resource "aws_security_group" "database" {
  name = "database"
  vpc_id = "${aws_vpc.DevEc2DbVpc.id}"
  description = "ONLY tcp CONNECTION INBOUND"
  tags {
    Name = "database"
	Environment = "${var.environment}"
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
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "DevEc2DbVpc" {
  cidr_block = "${var.vpc-cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "DevEc2DbVpc"
	Environment = "${var.environment}"
  }
}

