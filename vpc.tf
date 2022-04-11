resource "aws_internet_gateway" "internet-gw" {
    vpc_id = aws_vpc.ec2-s3-vpc.id
    tags = {
        Name = "Internet-GW"
    }
}
resource "aws_vpc" "ec2-s3-vpc" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "vpc-tf"
    }
}
resource "aws_subnet" "ec2-subnet" {
    vpc_id = aws_vpc.ec2-s3-vpc.id
    cidr_block = "192.168.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "vpc-subnet-tf"
    }
}
resource "aws_route_table" "route-table" {
    vpc_id = aws_vpc.ec2-s3-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gw.id
    }
    tags = {
        Name = "Public route table"
    }
    depends_on = [
      aws_internet_gateway.internet-gw
    ]
}
resource "aws_route_table_association" "route-subnet1" {
    subnet_id = aws_subnet.ec2-subnet.id
    route_table_id = aws_route_table.route-table.id
}
resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.ec2-s3-vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
}
resource "aws_vpc_endpoint_route_table_association" "vpc-endpoint" {
  route_table_id = aws_route_table.route-table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}