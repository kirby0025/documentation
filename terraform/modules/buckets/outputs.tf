#############
# APP OUTPUT
#############


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
