# Installation et configuration de mongoDB

## Configuration

La configuration se fait via le fichier ansible/group_vars/{{ nom_du_groupe }}.

## Variables
* mongodb_replicaset_name : Nom du replicaset configurés entre les serveurs. (Exemple: mongodb-stg)

## Fonctionnalités

* Installe les dépendances du rôle et de mongodb, le dépot MongoDB 6, les paquets mongodb.
* Déploie les outils de backups.
* Déploie la configuration relative à la supervision (check, fichier d'authentification et rôle custom).

## Tags

* install : installe mongodb, la supervision, les backups et les utilisateurs.
* supervision : met à jour les éléments relatifs à la supervision (check, configuration, rôle custom).
* backup: déploie les outils nécessaires aux sauvegardes (scripts, role, utilisateur, cron).

## Modification de configuration

* Mise à jour des éléments de supervision :
```
ansible-playbook -i hosts-stg playbooks/mongodb.yml -t supervision -l mongodb_stg
```
