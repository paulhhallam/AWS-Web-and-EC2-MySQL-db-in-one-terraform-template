<<<<<<< HEAD
output "public_ip" {
  description = "Public IP of the web server"
  value = "${aws_instance.webphpapp.public_ip}"
}

output "public_dns" {
  description = "Public DNS of the web server"
  value = "${aws_instance.webphpapp.public_dns}"
}
=======
output "public_ip" {
  description = "Public IP of the web server"
  value = "${aws_instance.webphpapp.public_ip}"
}

output "public_dns" {
  description = "Public DNS of the web server "
  value = "${aws_instance.webphpapp.public_dns}"
}
>>>>>>> 4cf8f1bff5475f49f8c4e53b611239fd946e1617
