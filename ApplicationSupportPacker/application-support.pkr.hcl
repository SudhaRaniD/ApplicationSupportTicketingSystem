
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

source "amazon-ebs" "application_support" {
  region        = var.aws_region
  instance_type = "t3.micro"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["amazon"]
    most_recent = true
  }

  ssh_username = "ec2-user"

  ami_name = "application-support-runtime-{{timestamp}}"

  tags = {
    Name    = "Application-Support-Runtime"
    Project = "ApplicationSupportTicketingSystem"
  }
}

build {
  sources = ["source.amazon-ebs.application_support"]

  provisioner "file" {
    source      = "../ApplicationSupportTerraform/prepare_runtime.sh"
    destination = "/tmp/prepare_runtime.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/prepare_runtime.sh",
      "sudo /tmp/prepare_runtime.sh"
    ]
  }
}
