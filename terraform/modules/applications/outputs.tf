output "app_name" {
    description = "Name of the application"
    value       = scaleway_iam_application.apps.name
}

output "app_id" {
    description = "ID of the application"
    value       = scaleway_iam_application.apps.id
}

output "app_desc" {
    description = "Description of the application"
    value       = scaleway_iam_application.apps.description
}

output "api_access_key" {
    description = "App access key"
    value       = scaleway_iam_api_key.keys.access_key
}

output "api_secret_key" {
    description = "App secret key"
    value       = scaleway_iam_api_key.keys.secret_key
}

##############
# BUCKET OUTPUT
##############

output "bucket_ID" {
    description = "ID of the bucket"
    value       = [ for b in scaleway_object_bucket.s3_buckets: b.id ]
}

output "bucket_endpoint" {
    description = "Bucket's endpoint"
    value       = [ for b in scaleway_object_bucket.s3_buckets: b.endpoint ]
}

##############
# SQS OUTPUT
##############

output "sqs_creds_access_key" {
    description = "SQS Credentials access key"
    value       = [ for c in scaleway_mnq_sqs_credentials.app_creds : c.access_key ]
}

output "sqs_creds_secret_key" {
    description = "SQS Credentials secret key"
    value       = [ for c in scaleway_mnq_sqs_credentials.app_creds : c.secret_key ]
}

output "sqs_url_endpoint" {
    description = "SQS URL Endpoint"
    value       = [ for c in scaleway_mnq_sqs_queue.main : c.url ]
}

##############
# SQS OUTPUT
##############

output "sns_creds_access_key" {
    description = "SNS Credentials access key"
    value       = [ for c in scaleway_mnq_sns_credentials.app_creds : c.access_key ]
}

output "sns_creds_secret_key" {
    description = "SNS Credentials secret key"
    value       = [ for c in scaleway_mnq_sns_credentials.app_creds : c.secret_key ]
}

output "sns_topic_arn" {
    description = "SNS Topic ARN"
    value       = [ for a in scaleway_mnq_sns_topic.main : a.arn ]
}
