variable "components" {
  default = [
    "frontend",
    "redis",
    "payment",
    "shipping",
    "dispatch",
    "mongodb",
    "cart",
    "catalogue",
    "rabbitmq",
    "user",
    "mysql"
  ]
}

data "aws_ami" "ami" {
  most_recent                   = true
  name_regex                    = "Centos-8-DevOps-Practice"
  owners                        = ["973714476881"]
}

resource "aws_instance" "instance" {
  count                         = length(var.components)
  ami                           = data.aws_ami.ami.id
  instance_type                 = "t3.micro"
  vpc_security_group_ids        = ["sg-00a0f8d9e29fb1216"]
  tags = {
    Name = element(var.components, count.index )
  }
}

resource "aws_route53_record" "record" {
  count                          = length(var.components)
  name                           = "${element(var.components, count.index)}-dev"
  type                           = "A"
  zone_id                        = "Z08999912AI7EUJ47AGDO"
  ttl                            = 30
  records                        = [element(aws_instance.instance.*.private_ip, count.index)]
}

resource "null_resource" "set-hostname" {
  count                          = length(var.components)
  provisioner "remote-exec" {
    connection {
      host = "element(aws_instance.instance.*.private_ip, count.index)"
      user = "root"
      password = "DevOps321"
    }
    inline = [
      "set-hostname -skip-apply ${var.components[count.index]}"
      ]
  }
}