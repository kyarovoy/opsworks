output "master_url" {
  value = "http://${aws_instance.master.public_ip}"
}