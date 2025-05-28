<!-- BEGIN_TF_DOCS -->
## Description du module

Ce module a pour but de gérer les applications et leur ressources associées dans le cloud public Scaleway.

## Fonctionnement du module

- Ce module prend en charge la gestion des ressources suivantes :
  - Les applications, groupes et policies de l'IAM Scaleway.
  - Les buckets S3 et de leur policy associée.
  - Les file d'attente de type SQS et leurs identifiants associés.

### Fonctionnement bucket S3

#### Pré-requis

- Une liste de bucket est déclarée au sein de l'application.
- Pour déclarer des règles de cycle de vie (lifecycle\_rules), au moins expiration\_days ou le couple transition\_days et transition\_sc doivent être déclarés.

#### Fonctionnement

- Pour chaque bucket de la liste buckets\_list, une resource va être déclarée. Dans cette ressource, une lifecycle\_rule va être déclarée pour chaque membre de la liste de lifecycle\_rule.
- Pour chaque bucket de la liste buckets\_list, une policy est attachée et contient 3 sections :
  - Une section pour autoriser l'application principale à accéder au bucket.
  - Une section pour donner accès aux user\_id et application\_id des administrateurs.
  - Une section pour donner accès à d'autres user\_id pour une application tierce.

### Fonctionnement SQS

#### Pré-requis

- Avoir activé le module SQS dans l'interface Scaleway -> Messaging.
- Une liste de queue est déclarée au sein de l'application.

#### Informations

- On utilise une resource de type scaleway\_mnq\_sqs\_credentials.admin\_creds par projet. En effet, en lui donnant uniquement le droit "can\_manage", elle peut créer, supprimer et modifier des queues mais pas accéder à leur contenu.
- En parallèle, on créé un jeu d'identifiant par application et par queue qui ne disposent que des droits de publication/réception.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | >= 2.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_iam_api_key.keys](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_api_key) | resource |
| [scaleway_iam_application.apps](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_application) | resource |
| [scaleway_iam_group.groups](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_group) | resource |
| [scaleway_iam_policy.group_policies](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_policy) | resource |
| [scaleway_object_bucket.s3_buckets](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_policy.s3_policies](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admins_user_id"></a> [admins\_user\_id](#input\_admins\_user\_id) | List of s3 admin user's ID | `list(string)` | `[]` | no |
| <a name="input_app_desc"></a> [app\_desc](#input\_app\_desc) | Application's description | `string` | `""` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application | `string` | `"changeme"` | no |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Application's tags | `map(string)` | `{}` | no |
| <a name="input_buckets_list"></a> [buckets\_list](#input\_buckets\_list) | List of the application's buckets | <pre>list(object({<br>            bucket_name            = string<br>            bucket_region          = optional(string)<br>            bucket_versioning      = optional(bool)<br>            bucket_tags            = optional(map(string))<br>            bucket_policy_actions  = optional(list(string))<br>            bucket_lifecycle_rules = optional(list(object({<br>                id              = string<br>                enabled         = bool<br>                prefix          = optional(string)<br>                expiration_days = optional(number)<br>                transition_days = optional(number)<br>                transition_sc   = optional(string)<br>                tags            = optional(map(string))<br>            })))<br>            other_app_access        = optional(list(string))<br>            other_app_policy_actions= optional(list(string))<br>    }))</pre> | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | App's environment (dev/stg/prd/inf) | `string` | `"dev"` | no |
| <a name="input_policy_permissions"></a> [policy\_permissions](#input\_policy\_permissions) | Policy permissions for app | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | App's project ID | `string` | `"changeme"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_access_key"></a> [api\_access\_key](#output\_api\_access\_key) | App access key |
| <a name="output_api_secret_key"></a> [api\_secret\_key](#output\_api\_secret\_key) | App secret key |
| <a name="output_app_desc"></a> [app\_desc](#output\_app\_desc) | Description of the application |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | ID of the application |
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | Name of the application |
| <a name="output_bucket_ID"></a> [bucket\_ID](#output\_bucket\_ID) | ID of the bucket |
| <a name="output_bucket_endpoint"></a> [bucket\_endpoint](#output\_bucket\_endpoint) | Bucket's endpoint |
<!-- END_TF_DOCS -->