resource "aws_instance" "ftestLinux" {
  ami               = var.amiUbuntu1804LTS[var.regionName]
  instance_type     = var.instanceType
  availability_zone = var.azFtnt1
  key_name          = var.keyName

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "20"
    volume_type           = "gp2"
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFTestPublic.id
    device_index         = 0
  }

  tags = {
    Name      = terraform.workspace == "default" ? var.hostnameFTest : "${var.hostnameFTest}-${terraform.workspace}"
    Terraform = true
    Project   = var.ProjectName
  }
}
