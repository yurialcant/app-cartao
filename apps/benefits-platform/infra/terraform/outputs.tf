output "s3_bucket_name" {
  value = aws_s3_bucket.benefits_storage.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.transaction_queue.url
}

output "sns_notifications_topic_arn" {
  value = aws_sns_topic.notifications.arn
}

output "sns_sms_topic_arn" {
  value = aws_sns_topic.sms.arn
}

output "ssm_sms_topic_arn_parameter" {
  value = aws_ssm_parameter.sms_topic_arn.name
}
