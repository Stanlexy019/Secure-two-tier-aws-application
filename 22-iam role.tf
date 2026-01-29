resource "aws_iam_role" "ec2_ssm_role" {
  name = "stanley-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile" # 👈 AWS NAME
  role = aws_iam_role.ec2_ssm_role.name
}

# Allow EC2 to read secrets from SSM Parameter Store
resource "aws_iam_policy" "ssm_read_app_secrets" {
  name        = "ssm-read-app-secrets"
  description = "Read app secrets from SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:eu-north-1:*:parameter/app/prod/*"
      }
    ]
  })
}
# Attach SSM read policy to EC2 role
resource "aws_iam_role_policy_attachment" "attach_ssm_read_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ssm_read_app_secrets.arn
}

