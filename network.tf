# Networking (VPC, RT, Subnets, etc...)
resource "aws_vpc" "grafana-vpc" {
  cidr_block       = "172.24.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "grafana-vpc"
    terraform_provisioned = "true"
  }
}

resource "aws_subnet" "grafana-subnet-1" {
  vpc_id = aws_vpc.grafana-vpc.id
  cidr_block       = "172.24.0.0/28"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "grafana-subnet-1"
    terraform_provisioned = "true"
  }
}

resource "aws_subnet" "grafana-subnet-2" {
  vpc_id = aws_vpc.grafana-vpc.id
  cidr_block       = "172.24.0.32/28"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "grafana-subnet-2"
    terraform_provisioned = "true"
  }
}


resource "aws_internet_gateway" "grafana-igw" {
  vpc_id = aws_vpc.grafana-vpc.id

  tags = {
    Name = "grafana-igw"
    terraform_provisioned = "true"
  }
}

# Creating Route Table for Public Subnet
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.grafana-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.grafana-igw.id
      }
    tags = {
        Name = "grafana-public-rt"
      }
}

resource "aws_route_table_association" "rt-associate-public-1" {
    subnet_id = aws_subnet.grafana-subnet-1.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt-associate-public-2" {
    subnet_id = aws_subnet.grafana-subnet-2.id
    route_table_id = aws_route_table.rt.id
}

