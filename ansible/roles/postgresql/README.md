# Installation et configuration de Postgresql

[TOC]

## Documentation

### Postgresql :
* [Postgresql Official Documentation](https://www.postgresql.org/docs/) (EN)
* [Postgresql Documentation Officielle](https://docs.postgresql.fr/) (FR)

### Modules Ansible :
* [Ansible Galaxy : Postgresql](https://galaxy.ansible.com/ui/repo/published/community/postgresql/) (EN)

## Configuration

### Variables
* postgresql_monitoring_(user/password) : Identifiants liés à la supervision et à pmm.
* postgresql_admin_role_attr_flags : Liste des rôles qu'on souhaite attribuer aux administrateurs. Défaut : CREATEDB,CREATEROLE,NOSUPERUSER.
* postgresql_pmm_server : Adresse du serveur PMM.
* postgresql_pmm_server_(username/password) : Identifiants utilisés pour se connecter au serveur PMM.
* postgresql_pmm_client_(username/password) : Identifiants utilisés pour se connecter au serveur Postgresql local.
* postgresql_users_networks : Liste des réseaux qui seront ajoutés au fichier pg_hba.conf pour les utilisateurs.
* postgresql_databases : Liste des bases de données à créer.
```
postgresql_databases:
    - name: "testsla"
      (optional) owner: "testsla"
      schemas:
        - name: "testsla_schema"
          owner: "testsla"

### Tags
* install : Installe Postgresql et ses dépendances.
* config : Gère les configurations, créer les utilisateurs et effectue les tâches liées au monitoring.
* backup : Installe les composants nécessaires aux sauvegardes.
* monitoring : Installe et configure pmm-client.
* databases : Créer les bases de données et leur schémas.

## Fonctionnement du rôle

### Basique pour comprendre Postgresql

#### Rôles, utilisateurs et permissions
* Un utilisateur correspond à un rôle avec un droit de login.
* Tous les utilisateurs font partie du groupe "public".

#### Base de données, schémas et tables.
* Une base de données contient un ou plusieurs schémas qui contiennent une ou plusieurs tables.
* Les bases de données contiennent par défaut un schema "public" sur lequel le groupe "public" a les droits de lecture.
