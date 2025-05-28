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
- Pour déclarer des règles de cycle de vie (lifecycle_rules), au moins expiration_days ou le couple transition_days et transition_sc doivent être déclarés.

#### Fonctionnement

- Pour chaque bucket de la liste buckets_list, une resource va être déclarée. Dans cette ressource, une lifecycle_rule va être déclarée pour chaque membre de la liste de lifecycle_rule.
- Pour chaque bucket de la liste buckets_list, une policy est attachée et contient 3 sections :
  - Une section pour autoriser l'application principale à accéder au bucket.
  - Une section pour donner accès aux user_id et application_id des administrateurs.
  - Une section pour donner accès à d'autres user_id pour une application tierce.

### Fonctionnement SQS

#### Pré-requis

- Avoir activé le module SQS dans l'interface Scaleway -> Messaging.
- Une liste de queue est déclarée au sein de l'application.

#### Informations

- On utilise une resource de type scaleway_mnq_sqs_credentials.admin_creds par projet. En effet, en lui donnant uniquement le droit "can_manage", elle peut créer, supprimer et modifier des queues mais pas accéder à leur contenu.
- En parallèle, on créé un jeu d'identifiant par application et par queue qui ne disposent que des droits de publication/réception.
