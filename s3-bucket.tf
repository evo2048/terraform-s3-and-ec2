resource "aws_s3_bucket" "only-ec2-role-access" {
    bucket = "only-ec2-role-access"
    tags = {
      Name = "Bucket Name"
    }
}
resource "aws_s3_bucket_policy" "VPC-Access-Policy" {
  bucket = aws_s3_bucket.only-ec2-role-access.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
        Sid = "Access from specific VPC"
        Action = "s3:*"
        Effect = "Deny"
        Principal = "*"
        Resource = [
          aws_s3_bucket.only-ec2-role-access.arn,
          "${aws_s3_bucket.only-ec2-role-access.arn}/*"
        ]
        Condition = {
          StringNotEquals= {
            "aws:SourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      }
  })
}
