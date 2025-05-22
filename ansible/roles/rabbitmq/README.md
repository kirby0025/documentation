# Installation et configuration de RabbitMQ

## Documentation

### RabbitMQ :
* [RabbitMQ Production Checklist](https://www.rabbitmq.com/production-checklist.html)
* [RabbitMQ Prometheus exporter](https://www.rabbitmq.com/prometheus.html)
* [RabbitMQ Config file exemple complet](https://github.com/rabbitmq/rabbitmq-server/blob/v3.12.x/deps/rabbit/docs/rabbitmq.conf.example)
* [RabbitMQ Authorisation and access control](https://rabbitmq.com/access-control.html)
* [RabbitMQctl](https://www.rabbitmq.com/rabbitmqctl.8.html)
### Modules ansible-galaxy :
* [Ansible Galaxy : Rabbitmq](https://galaxy.ansible.com/ui/repo/published/community/rabbitmq/)


## Configuration

Les modifications de configuration sont à faire dans le fichier [templates/rabbitmq.conf.j2](templates/rabbitmq.conf.j2)

## Variables
* rabbitmq_cluster_name : Nom du cluster rabbitq. (Default: default)
* rabbitmq_cluster_nodes : Liste des noeuds appartenant au cluster.
* rabbitmq_admin_username : Nom de l'utilisateur admin. (Default : admin)
* rabbitmq_admin_password : Mot de passe de l'utilisateur admin.
* rabbitmq_plugins: Liste des plugins Rabbitmq à installer. (Default : rabbitmq_management,rabbitmq_shovel,rabbitmq_prometheus)
* rabbitmq_vhosts : Liste des vhosts. (Default : "/")
* rabbitmq_app_users : Liste des utilisateurs applicatifs à créer. Par défaut les utilisateurs ont tous les privilèges sur le vhost.
```
rabbitmq_app_users:
    - username: "consult"
      password: "{{ lookup('community.hashi_vault.hashi_vault', 'ansible/data/rabbitmq/{{ env }}/users/consult:password') }}"
      vhost: "consult"
```
## Fonctionnalités

* Installe les dépendances du rôle, rabbitmq et erlang.
* Supprime l'utilisateur guest créé par défaut et créer un utilisateur admin.
* Active les plugins de management (interface web), prometheus (exporter intégré) et shovel.
* Déploie les utilisateurs et les vhosts applicatifs.

## Tags

* install : installe rabbitmq et ses dépendances.
* config : supprime l'utilisateur guest, créer l'utilisateur admin, les vhosts et les utilisateurs applicatifs.
* users: deploie les utilisateurs et les vhosts.
* vhosts: deploie les vhosts.
* exchanges: deploie les exchanges.

## Premier lancement pour création d'un cluster

1. Lancer le playbook avec le tag install :
```
ansible-playbook -l rabbitmq_cluster playbooks/rabbitmq.yml -t install
```
2. Se rendre sur les machines 2 et 3 et renseigner les commandes suivantes pour créer le cluster :
```
rabbitmqctl stop_app
rabbitmqctl --longnames join_cluster node1.example.net
rabbitmqctl start_app
```
3. Lancer le playbook avec le tag config :
```
ansible-playbook -l rabbitmq_cluster playbooks/rabbitmq.yml -t config
```

## Modification de configuration

* Création de toutes les ressources : users, vhost, exchange, queues et bindings :
```
ansible-playbook playbooks/rabbitmq.yml -t config -l rabbitmq_cluster
```

* Déploiement des utilisateurs applicatifs et des vhosts :
```
ansible-playbook playbooks/rabbitmq.yml -t users -l rabbitmq_cluster
```

## Tests de performance

[RabbitMQ perf-tests](https://github.com/rabbitmq/rabbitmq-perf-test)

### Pré-requis
* Installer Java
* Créer un utilisateur avec tous les droits sur un vhost dédiés.
```
rabbitmqctl add_vhost testsla
rabbitmqctl add_user test_sla sebisdown -p testsla
rabbitmqctl set_permissions -p testsla test_sla ".*" ".*" ".*"
```

### Exemple de test
* Test sur une quorum-queue nommée 'qq', avec des messages de 4Ko publiés par 5 process et consommés par 15 process. Avec des taux variables : 200 msg/process/seconde pendant 240 secondes puis 400 msg/process/seconde pendant 120 secondes puis 300 msg/process/seconde pendant 120 secondes, en boucle.
```
java -jar perf-test-2.20.0.jar -h amqp://test_sla:sebisdown@rabbitmq-vip.example.com:5674/testsla --quorum-queue --queue qq --size 4000  --variable-rate 200:240 --variable-rate 400:120 --variable-rate 300:120 --producers 5 --consumers 15
```
* Test illimité avec un seul publieur et un consommateur.
```
java -jar perf-test-2.20.0.jar -h amqp://test_sla:sebisdown@rabbitmq-vip.example.com:5674/testsla
```
* Test illimité sur une quorum-queue avec un seul publieur et un consommateur.
```
java -jar perf-test-2.20.0.jar -h amqp://test_sla:sebisdown@rabbitmq-vip.example.com:5674/testsla --quorum-queue --queue qq
```
* Test illimité sur une quorum-queue avec un taux de 100 msg/secondes pour un seul publieur et un seul consommateur.
```
java -jar perf-test-2.20.0.jar -h amqp://test_sla:sebisdown@rabbitmq-vip.example.com:5674/testsla --quorum-queue --queue qq --rate 100
```
