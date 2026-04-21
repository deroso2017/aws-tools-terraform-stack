data "aws_ami" "amazon-linux-2023" { # Find the latest Amazon Linux 2023 AMI
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.public
  vpc_security_group_ids      = [aws_security_group.app.id]
  depends_on                  = [aws_vpc.main, aws_subnet.public, aws_security_group.app]
  user_data_replace_on_change = true

  tags = {
    Name     = "bastion-host"
    AMI_Name = data.aws_ami.amazon-linux-2023.name
  }
}
