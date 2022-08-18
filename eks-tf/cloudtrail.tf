data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "trail" {
  name                          = "tf-trail-populare"
  s3_bucket_name                = aws_s3_bucket.trail_populare.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = false
}

resource "aws_s3_bucket" "trail_populare" {
  bucket        = "tf-trail-populare"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "trail_populare" {
  bucket = aws_s3_bucket.trail_populare.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.trail_populare.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.trail_populare.arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
