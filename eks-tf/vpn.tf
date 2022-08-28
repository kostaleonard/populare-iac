resource "aws_instance" "bulwark" {
  ami                         = "ami-05803413c51f242b7" # us-east-2
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  # SSH username for these EC2 instances is "ubuntu".
  key_name = "bulwark_ssh_key"

  user_data = templatefile("${path.module}/bulwark_bootstrap.tftpl", {})

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bulwark.id]
  tags = {
    Name = "bulwark"
  }
}

resource "aws_key_pair" "bulwark_ssh_key" {
  key_name = "bulwark_ssh_key"
  # Leo's PC.
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTQwGhjFRWQccBre/mDCMo7rWmFlyVJ+i+1iFjUpF4t kostaleonard@gmail.com"
}

resource "aws_security_group" "bulwark" {
  name   = "bulwark"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bulwark"
  }
}
