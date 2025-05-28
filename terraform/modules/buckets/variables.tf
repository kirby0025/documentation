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
    description = "App's environment (dev/stg/prd/inf)"
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
