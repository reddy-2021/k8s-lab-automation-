provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "k8s_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/my-key.pub")
}

resource "aws_security_group" "k8s_sg" {
  name = "k8s-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = { Name = "k8s-master" }
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = { Name = "k8s-worker-${count.index}" }
}

# 🔥 AUTO INVENTORY GENERATION
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<EOF
[k8s_master]
${aws_instance.master.public_ip}

[k8s_workers]
%{ for ip in aws_instance.worker[*].public_ip ~}
${ip}
%{ endfor }

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=../terraform/my-key.pem
EOF
}
