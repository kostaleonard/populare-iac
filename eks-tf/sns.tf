resource "aws_sns_topic" "populare_user_updates" {
  name = "populare-user-updates-topic"
}

resource "aws_sns_topic_subscription" "populare_user_updates_email_target" {
  topic_arn = aws_sns_topic.populare_user_updates.arn
  # TODO email is partially supported because it requires user confirmation, but terraform destroy of the aws_sns_topic should correctly remove the subscription
  # See Terraform docs linked below for notes on partially supported protocols.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
  protocol  = "email"
  endpoint  = "kostaleonard@gmail.com"
}
