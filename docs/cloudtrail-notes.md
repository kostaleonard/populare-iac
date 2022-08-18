# CloudTrail notes

CloudTrail allows us to log and audit AWS API calls in our environment. The
logs are written to S3 by default and can also be integrated into CloudWatch
and SNS. Terraform deployments create a series of predictable events in
CloudTrail, e.g., CreateBucket, CreateNetworkInterface; deviations from these
patterns could trigger alerts and automated responses (e.g., via Lambda).
