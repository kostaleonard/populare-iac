resource "aws_flow_log" "populare" {
  iam_role_arn    = aws_iam_role.populare_flow_log.arn
  log_destination = aws_cloudwatch_log_group.populare.arn
  # Log traffic within the VPC.
  traffic_type = "ALL"
  vpc_id       = module.vpc.vpc_id
}

resource "aws_cloudwatch_log_group" "populare" {
  name = "populare"
}

resource "aws_iam_role" "populare_flow_log" {
  name = "populare-flow-log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "populare_flow_log_policy" {
  name = "populare-flow-log-policy"
  role = aws_iam_role.populare_flow_log.id

  # This policy differs slightly from the Terraform default implementation. In
  # particular, we have removed "logs:CreateLogGroup" based on a comment here
  # that seemed to work: https://github.com/hashicorp/terraform/issues/14750#issuecomment-303337513
  # The reason that the change works has to do with a nuance in the AWS API.
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
