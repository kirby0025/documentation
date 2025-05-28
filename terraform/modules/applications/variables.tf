###################
# GLOBAL VARIABLES
###################

variable "project_id" {
    description = "App's project ID"
    type        = string
    default     = "changeme"
}
###################
# APP VARIABLES
###################

variable "app_name" {
    description = "Name of the application"
    type        = string
    default     = "changeme"
}

variable "app_desc" {
    description = "Application's description"
    type        = string
    default     = ""
}

variable "app_tags" {
    description = "Application's tags"
    type        = map(string)
    default     = {}
}

variable "env" {
    description = "App's environment (dev/stg/prd)"
    type        = string
    default     = "dev"
}

variable "policy_permissions" {
    description = "Policy permissions for app"
    type        = list(string)
    default     = []
}

###################
# BUCKETS VARIABLE
###################

variable "buckets_list" {
    description = "List of the application's buckets"
    type        = list(object({
            bucket_name            = string
            bucket_region          = optional(string)
            bucket_versioning      = optional(bool)
            bucket_tags            = optional(map(string))
            bucket_policy_actions  = optional(list(string))
            bucket_lifecycle_rules = optional(list(object({
                id              = string
                enabled         = bool
                prefix          = optional(string)
                expiration_days = optional(number)
                transition_days = optional(number)
                transition_sc   = optional(string)
                tags            = optional(map(string))
            })))
            other_app_access        = optional(list(string))
            other_app_policy_actions= optional(list(string))
    }))
}


# 09/01/2024 - Pas possible de mettre des group_id comme principal
# cf https://feature-request.scaleway.com/posts/714/bucket-policy-with-group_id
variable "admins_user_id" {
    description = "List of s3 admin user's ID"
    type        = list(string)
    default     = []
}
variable "readonly_users_id" {
    description = "List of readonly user's ID"
    type        = list(string)
    default     = []
}

###################
# SQS VARIABLES
###################

variable "sqs_queue_list" {
    description = "List of the SQS queues"
    type        = list(object({
            sqs_queue_name  = string
            sqs_fifo_queue  = optional(bool)
            sqs_message_max_age = optional(string)
            sqs_message_max_size= optional(string)
    }))
}

variable "sqs_can_manage" {
    description = "Can SQS credentials manage the queue"
    type        = bool
    default     = false
}

variable "sqs_can_receive" {
    description = "Can SQS credentials receive message from the queue"
    type        = bool
    default     = true
}

variable "sqs_can_publish" {
    description = "Can SQS credentials publish message to the queue"
    type        = bool
    default     = true
}

variable "sqs_fifo_queue" {
    description = "Is the queue in FIFO mode ?"
    type        = bool
    default     = false
}

variable "sqs_message_max_age" {
    description = "Max age of message before being deleted in seconds"
    type        = number
    default     = 345600
}

variable "sqs_message_max_size" {
    description = "Max size of message accepted in octet"
    type        = number
    default     = 262144
}

variable "admin_creds_access_key" {
    description = "SQS Admin access key"
    type        = string
    default     = ""
}

variable "admin_creds_secret_key" {
    description = "SQS Admin secret key"
    type        = string
    default     = ""
}

###################
# SNS VARIABLES
###################

variable "sns_topic_list" {
    description = "List of the SNS topics"
    type        = list(object({
            sns_topic_name  = string
            sns_fifo_topic  = optional(bool)
    }))
}

variable "sns_can_manage" {
    description = "Can SNS credentials manage the topic"
    type        = bool
    default     = false
}

variable "sns_can_receive" {
    description = "Can SNS credentials receive message from the topic"
    type        = bool
    default     = true
}

variable "sns_can_publish" {
    description = "Can SNS credentials publish message to the topic"
    type        = bool
    default     = true
}

variable "sns_fifo_topic" {
    description = "Is the topic in FIFO mode ? (name must end with .fifo)"
    type        = bool
    default     = false
}

variable "sns_admin_creds_access_key" {
    description = "SNS Admin access key"
    type        = string
    default     = ""
}

variable "sns_admin_creds_secret_key" {
    description = "SNS Admin secret key"
    type        = string
    default     = ""
}
