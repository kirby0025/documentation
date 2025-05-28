resource "scaleway_mnq_sqs_credentials" "app_creds" {
    for_each    = (var.sqs_queue_list == null) ? {} : {for q in var.sqs_queue_list : q.sqs_queue_name => q }

    project_id  = var.project_id
    name        = "${var.app_name}-${each.value.sqs_queue_name}"
    permissions {
        can_manage  = false
        can_receive = var.sqs_can_receive
        can_publish = var.sqs_can_publish
    }
}

resource "scaleway_mnq_sqs_queue" "main" {
    for_each    = (var.sqs_queue_list == null) ? {} : {for q in var.sqs_queue_list : q.sqs_queue_name => q }

    project_id      = var.project_id
    name            = each.value.sqs_queue_name
    access_key      = var.admin_creds_access_key
    secret_key      = var.admin_creds_secret_key

    fifo_queue      = each.value.sqs_fifo_queue
    message_max_age = each.value.sqs_message_max_age
    message_max_size= each.value.sqs_message_max_size

    depends_on  = [
        scaleway_mnq_sqs_credentials.app_creds
    ]
}
