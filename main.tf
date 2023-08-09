terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  # Configuration options
  region                   = var.region
  shared_config_files      = ["C:\\Users\\Abdelrahman Gaber\\.aws\\config"]
  shared_credentials_files = ["C:\\Users\\Abdelrahman Gaber\\.aws\\credentials"]
  profile                  = var.profile
}


# Define ami image
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
# Create new key pair
resource "aws_key_pair" "dev_key" {
  key_name   = "dev_key"
  public_key = file("~/.ssh/terra_key.pub")
}

# Create New t3.micro ec2 instance
resource "aws_instance" "dev_ec2" {
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.ubuntu_22_04.id
  key_name               = aws_key_pair.dev_key.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.dev_subnet.id
  user_data              = file("ubuntu_userdata.tpl")
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "DEV Ubuntu-22.04 EC2"
  }
  # Use provisioner to auto add the ssh connection credentials
  provisioner "local-exec" {
    command = templatefile("windows_ssh_config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu"
      identityfile = "~/.ssh/terra_key"
    })
    interpreter = ["Powershell", "-Command"]
  }
}

