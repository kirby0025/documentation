resource "scaleway_mnq_sns_credentials" "app_creds" {
    for_each    = (var.sns_topic_list == null) ? {} : {for q in var.sns_topic_list : q.sns_topic_name => q }

    project_id  = var.project_id
    name        = "${var.app_name}-${each.value.sns_topic_name}"
    permissions {
        can_manage  = false
        can_receive = var.sns_can_receive
        can_publish = var.sns_can_publish
    }
}

resource "scaleway_mnq_sns_topic" "main" {
    for_each    = (var.sns_topic_list == null) ? {} : {for q in var.sns_topic_list : q.sns_topic_name => q }

    project_id      = var.project_id
    name            = each.value.sns_topic_name
    access_key      = var.sns_admin_creds_access_key
    secret_key      = var.sns_admin_creds_secret_key

    depends_on  = [
        scaleway_mnq_sns_credentials.app_creds
    ]
}
