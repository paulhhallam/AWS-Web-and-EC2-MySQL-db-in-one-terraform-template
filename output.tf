output "public_ip" {
  description = "Public IP of the web server"
  value = "${aws_instance.webphpapp.public_ip}"
}

output "public_dns" {
  description = "Public DNS of the web server "
  value = "${aws_instance.webphpapp.public_dns}"
}
