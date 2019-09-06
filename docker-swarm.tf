
resource "aws_instance" "master" {
  ami                    = var.swarm_instance_ami
  instance_type          = var.swarm_instance_type
  vpc_security_group_ids = ["${aws_security_group.swarm.id}"]
  key_name               = "${aws_key_pair.deployer.key_name}"
  subnet_id              = "${aws_subnet.swarm_subnet.id}"
  depends_on             = ["aws_internet_gateway.main"]

  connection {
    host        = "${self.public_ip}"
    user        = "ubuntu"
    private_key = "${tls_private_key.opsworks.private_key_pem}"
  }

  provisioner "file" {
    source      = "proj"
    destination = "/home/ubuntu/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt -y update",
      "sudo apt -y install docker-ce",
      "sudo systemctl enable --now docker",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token",
      "sudo docker service create --name registry --publish published=5000,target=5000 registry:2",
      "cd proj",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo docker-compose build",
      "sudo docker-compose push",
      "sudo docker stack deploy --compose-file docker-compose.yml sampleapp"
    ]
  }

  tags = {
    Name = var.nametag
  }
}

resource "aws_instance" "slave" {
  count                  = var.swarm_worker_count
  ami                    = var.swarm_instance_ami
  instance_type          = var.swarm_instance_type
  vpc_security_group_ids = ["${aws_security_group.swarm.id}"]
  subnet_id              = "${aws_subnet.swarm_subnet.id}"
  key_name               = "${aws_key_pair.deployer.key_name}"
  depends_on             = ["aws_instance.master"]
  connection {
    host        = "${self.public_ip}"
    user        = "ubuntu"
    private_key = "${tls_private_key.opsworks.private_key_pem}"
  }
  provisioner "file" {
    content      = "${tls_private_key.opsworks.private_key_pem}"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt -y update",
      "sudo apt -y install docker-ce",
      "sudo systemctl enable --now docker",
      "sudo chmod 400 /home/ubuntu/.ssh/id_rsa",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i /home/ubuntu/.ssh/id_rsa ubuntu@${aws_instance.master.private_ip}:/home/ubuntu/token .",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.master.private_ip}:2377"
    ]
  }
  tags = {
    Name = var.nametag
  }
}