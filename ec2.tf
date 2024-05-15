
resource "aws_security_group" "grafana-sg" {
  name = "grafana-sg"
  vpc_id      = aws_vpc.grafana-vpc.id

  dynamic "ingress" {
    for_each = var.ingress_ports
  
    content {
      from_port   = ingress.value["ports"]
      to_port     = ingress.value["ports"]
      protocol    = "tcp"
      cidr_blocks = [ingress.value["source"]]
      description = ingress.value["description"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grafana-sg"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] 
  }
  
}
resource "aws_instance" "grafana_smidige" {

  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3a.medium"

  vpc_security_group_ids = [ aws_security_group.grafana-sg.id]
  subnet_id = aws_subnet.grafana-subnet-1.id

  associate_public_ip_address = true

  tags = {
    Name = "smidige-grafana"
  }

  user_data =  <<-EOF
                #!/bin/bash
                yum update -y
                echo -e "[grafana]\nname=grafana\nbaseurl=https://packages.grafana.com/oss/rpm\nrepo_gpgcheck=1\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.grafana.com/gpg.key\nsslverify=1\nsslcacert=/etc/pki/tls/certs/ca-bundle.crt" >> /etc/yum.repos.d/grafana.repo
                yum install grafana -y
                systemctl start grafana-server
                systemctl daemon-reload
                systemctl enable grafana-server.service

                EOF

}

resource "aws_eip" "lb" {
  instance = aws_instance.grafana_smidige.id
  domain   = "vpc"

  depends_on = [ aws_internet_gateway.grafana-igw ]
}