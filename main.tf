provider "aws"{
region = "us-east-1"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.13.0.0/16"

}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.13.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "nic" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.13.10.100"]
  security_groups = [aws_security_group.aws_sg.id]
  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_security_group" "aws_sg" {
  name        = "aws_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id
}
resource "aws_security_group_rule" "inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_sg.id
}
resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.aws_sg.id
}
variable "privatekey"{
default = "deployer"
}
resource "aws_instance" "my_instance" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${path.module}/id_rsa")}"
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key /home/ubuntu/terraform/id_rsa   /home/ubuntu/terraform/apache_source.yml"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9Zs2KN0ozu1/DeM1d4j0FC8YzNv0sRKb44xNuDa2qkEI2AScPYBhGbefTmzqqa7OiPn2yL69K7yyAHv4F0kaF/jZlbyqhYQSEU+pIQahvSyqtq1LuOaPYFhqwXNTWt+H/LIolI/h6cksPbq0AUsVi7yolz2R7WIGm47WLjtka4erofF1d4tPacJNXJ3BEA2Xm5TbJLo1O/jYDLzWIa52XsQvgG+dpuu4FMLP+6UJsfMWbdzlUEvJoO5fMpL6KOyhAQaZm7FvnaT4KraTP0bH2I5HIyQHb9FltqdPg9ohUuyShEmjGzoRbjXPv/gqZqBaSrt8oqWof4L8sFD+5om+tnffmhkhEy5928V2mNzwGW76AwzBmYjT0Brm+7bcK64krDfacbIci+K0UtwFLGMdDcOn1n82rDdWfnfotxeAol+mJLKPsUHj5571CZrsaC89udtSNUtGncEiO+vXXQviMSEr6SconVk3FEF28zSuV7o6zTA/jkFX51uEmHUc8V9U= ubuntu@ip-172-31-82-233"
}
