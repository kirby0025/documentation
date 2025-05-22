# Bastion deployment role

## Description

Ce rôle a pour but de créer un bastion ssh avec des configurations sécurisées au niveau réseau (nftables et fail2ban) et système (ssh,sudoers).
- Déploie les utilisateurs et leur clé publique.
- Déploie les clés publiques autorisés à se connecter au compte root et limité au connexion depuis 10.17.0.0/16.
- Déploie la configuration sudoers pour que les utilisateurs puissent se connecter au compte root.
- Déploie la configuration nftables et fail2ban.
- Déploie la configuration ssh.

## Variables

- private_networks: Réseaux privés utilisés pour l'administration.
- allowed_networks: Réseaux en liste blanche dans fail2ban.
- admin_users: Liste des utilisateurs autorisés à se connecter avec leur clé publique.
- rundeck_user: Clé publique de rundeck_inf
- dev_users: Liste des utilisateurs normaux à créer
- fail2ban_ignore_ips : Liste des IPs/network à ignorer pour fail2ban

## Installation

1. Installer la machine à partir d'un template existant.
2. Désactiver la configuration par DHCP sur l'interface privée
```bash
vim /etc/network/interfaces
iface <interface> inet static
    address <private_ip/netmask>
```
3. ansible-playbook -i hosts-dmz playbooks/bastion.yml -t all -l <hostname>

## Usage

- Déployer un bastion complet
```
ansible-playbook -i hosts-dmz playbooks/bastion.yml -t all
```
- Modifier les configurations de pare-feu
```
vim roles/bastion/templates/nftables.conf.j2
ansible-playbook -i hosts-dmz playbooks/bastion.yml -t firewall
```
- Modifier/Ajouter un utilisateur
```
vim group_vars/all
ansible-playbook -i hosts-dmz playbooks/bastion.yml -t users,ssh
```
- Modifier la configuration SSH
```
vim roles/bastion/templates/sshd_config.j2
ansible-playbook -i hosts-dmz playbooks/bastion.yml -t ssh
```

## Questions/TODO

- SSH 2FA
