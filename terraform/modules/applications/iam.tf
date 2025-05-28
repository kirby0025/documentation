resource "scaleway_iam_application" "apps" {
    name        = "${var.app_name}-${var.env}"
    description = "${var.app_desc} env : ${var.env}"
}

resource "scaleway_iam_api_key" "keys" {
    application_id      = scaleway_iam_application.apps.id
    description         = "${var.app_name}-${var.env} api key"
    default_project_id  = var.project_id

    depends_on = [
        scaleway_iam_application.apps
    ]
}

resource "scaleway_iam_group" "groups" {
    name            = "group-${var.app_name}-${var.env}"
    description     = "${var.app_name} IAM group for env ${var.env}"

    application_ids = [
        scaleway_iam_application.apps.id
    ]

    depends_on = [
        scaleway_iam_application.apps
    ]
}

resource scaleway_iam_policy "group_policies" {
    name        = "policy-${var.app_name}-${var.env}"
    description = "${var.app_name} policy for group ${scaleway_iam_group.groups.name} in env ${var.env}"
    group_id    = scaleway_iam_group.groups.id
    rule {
        project_ids         = [var.project_id]
        permission_set_names = var.policy_permissions
    }

    depends_on = [
        scaleway_iam_group.groups
    ]
}
