resource "aws_instance" "ec2-and-s3-bucket" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.EC2-profile.name
  subnet_id                   = aws_subnet.ec2-subnet.id
  vpc_security_group_ids      = [aws_security_group.s3-ec2-group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.new_key.key_name
  depends_on = [
    aws_internet_gateway.internet-gw
  ]
}

resource "aws_network_interface" "net-int" {
  subnet_id   = aws_subnet.ec2-subnet.id
  private_ips = ["192.168.0.50"]
}

resource "aws_iam_role" "S3-access" {
  name = "S3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "ec2-role-s3-bucket-access"
  }
}

resource "aws_iam_role_policy" "S3-full-access-policy" {
  name = "s3-full-access"
  role = aws_iam_role.S3-access.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "EC2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.S3-access.name
}

resource "aws_security_group" "s3-ec2-group" {
  vpc_id = aws_vpc.ec2-s3-vpc.id
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  }]
}

resource "aws_key_pair" "new_key" {
  key_name   = "aws_key"
  public_key = "SSH-PUBLIC-KEY-HERE"
}
