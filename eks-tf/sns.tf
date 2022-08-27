resource "aws_sns_topic" "populare_user_updates" {
  name = "populare-user-updates-topic"
}

resource "aws_sqs_queue" "populare_user_updates" {
  name                      = "populare-user-updates-queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
}

resource "aws_sns_topic_subscription" "populare_user_updates_sqs_target" {
  topic_arn = aws_sns_topic.populare_user_updates.arn
  # See Terraform docs linked below for notes on partially supported protocols.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.populare_user_updates.arn
}

resource "aws_sqs_queue_policy" "user_updates_queue_policy" {
  queue_url = aws_sqs_queue.populare_user_updates.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "sqs:SendMessage",
    "Resource": "${aws_sqs_queue.populare_user_updates.arn}",
    "Condition": {
      "ArnEquals": {
        "aws:SourceArn": "${aws_sns_topic.populare_user_updates.arn}"
      }
    }
  }]
}
POLICY
}
