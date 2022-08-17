resource "aws_instance" "bulwark" {
  ami           = "ami-05803413c51f242b7" # us-east-2
  # TODO add name
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "bulwark_ssh_key"

  # TODO docker run VPN server
  # TODO change directory from /tmp/bulwark-config
  # TODO use template file to set the server url if that makes config easier
#  user_data     = <<-EOF
#                  #!/bin/bash
#                  sudo su
#                  yum -y install httpd
#
#                  docker run -d \
#                    --rm \
#                    --name=bulwark \
#                    --cap-add=NET_ADMIN \
#                    --cap-add=SYS_MODULE \
#                    -e PUID=1000 \
#                    -e PGID=1000 \
#                    -e TZ=Europe/London \
#                    -e PEERS=leo_mac \
#                    -e SERVERURL=0.0.0.0 \
#                    -e SERVERPORT=51820 \
#                    -e INTERNAL_SUBNET=10.13.13.0 \
#                    -e PEERDNS=auto \
#                    -p 51820:51820/udp \
#                    -v /tmp/bulwark-config:/config \
#                    -v /lib/modules:/lib/modules \
#                    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
#                    linuxserver/wireguard
#                  EOF

  subnet_id = module.vpc.public_subnets[0]
  # TODO do we need to explicitly define the private IP for it to get a private interface? We don't really care what the IP is.
  private_ip = "10.0.4.40"
  # TODO add security group rule to allow 22 and 51280
  security_groups = [] # TODO
  tags = {
    Name = "bulwark"
  }
}

resource "aws_key_pair" "bulwark_ssh_key" {
  key_name   = "bulwark_ssh_key"
  # Leo's PC.
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTQwGhjFRWQccBre/mDCMo7rWmFlyVJ+i+1iFjUpF4t kostaleonard@gmail.com"
}

#resource "aws_subnet" "bulwark" {
#  vpc_id            = module.vpc.vpc_id
#  # TODO can we make this not hard-coded?
#  cidr_block        = "10.0.7.0/24"
#  availability_zone = module.vpc.azs[0]
#}
#
#data "aws_subnet_ids" "public" {
#  vpc_id = module.vpc.vpc_id
#}

#resource "aws_network_interface" "bulwark" {
#  # TODO security group settings
#  subnet_id   = aws_subnet.bulwark.id
#}
