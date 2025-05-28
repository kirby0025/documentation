resource "scaleway_object_bucket" "s3_buckets" {
    for_each    = (var.buckets_list == null) ? {} : { for b in var.buckets_list : b.bucket_name => b }

    name        = each.value.bucket_name
    tags        = each.value.bucket_tags
    region      = each.value.bucket_region
    project_id  = var.project_id
    versioning {
        enabled = each.value.bucket_versioning
    }

    /*  Dans cette section, on ajoute un bloc lifecycle_rule pour chaque
        élément présent dans la liste lifecycle_rules de l'objet buckets.
    */
    dynamic "lifecycle_rule" {
        for_each = each.value.bucket_lifecycle_rules
        content {
            id          = lifecycle_rule.value["id"]
            prefix      = lifecycle_rule.value["prefix"]
            enabled     = lifecycle_rule.value["enabled"]
            tags        = lifecycle_rule.value["tags"]
            /*  On ajoute les blocs expiration ou transition en fonction
                de la présence ou non des variables expiration_days,
                transition_days et transition_sc. Au moins l'un de ces blocs
                est obligatoire pour que la règle soit valide.
            */
            dynamic "expiration" {
                for_each = lifecycle_rule.value["expiration_days"] == null ? [] : [1]
                content {
                    days    = lifecycle_rule.value["expiration_days"]
                }
            }
            dynamic "transition" {
                for_each = (lifecycle_rule.value["transition_days"] == null) && (lifecycle_rule.value["transition_sc"] == null) ? [] : [1]
                content {
                    days            = lifecycle_rule.value["transition_days"]
                    storage_class   = lifecycle_rule.value["transition_sc"]
                }
            }
        }
    }

    depends_on = [
        scaleway_iam_api_key.keys
    ]
}

resource "scaleway_object_bucket_policy" "s3_policies" {
    for_each    = (var.buckets_list == null) ? {} : { for b in var.buckets_list : b.bucket_name => b }

    bucket  = each.value.bucket_name
    policy  = jsonencode({
        Version     = "2023-04-17",
        Id          = "${each.value.bucket_name}",
        Statement   = [
            {
                Sid         = "RW-${each.value.bucket_name}",
                Effect      = "Allow",
                Principal   = {
                    SCW = "application_id:${scaleway_iam_application.apps.id}"
                },
                Action      = "${each.value.bucket_policy_actions}",
                Resource    = [
                    "${each.value.bucket_name}",
                    "${each.value.bucket_name}/*"
                ],
            },
            {
                Sid         = "Admin-${each.value.bucket_name}",
                Effect      = "Allow",
                Principal   = {
                    SCW = var.admins_user_id
                },
                Action      = "s3:*",
                Resource    = [
                    "${each.value.bucket_name}",
                    "${each.value.bucket_name}/*"
                ],
            }
        ]
    })

    depends_on = [
        scaleway_object_bucket.s3_buckets
    ]
}
