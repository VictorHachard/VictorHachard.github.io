---
title: OVH PCA
layout: note
draft: false
date: 2021-08-11 15:35:00 +0200
author: Victor Hachard
---

## Préambule

L’archive nuageuse OVH est basée sur Openstack Swift. Même si OVH mène l’effort pour faciliter l’utilisation du stockage d’objets, il hérite par la force des concepts fondamentaux qui peuvent paraître surprenants à un nouvel utilisateur. Ce guide répondra aux questions les plus fréquemment posées par les utilisateurs.

## Questions

### Pourquoi ai-je un conteneur portant le suffixe “_segments” après s’être connecté aux passerelles pour les transferts scp/sftp/rsync ?

Pour le transfert de fichiers volumineux il faut, Openstack Swift fournit un mécanisme utilisant des segments et des manifestes. Toute archive supérieure à 256 Mo transférée par ces passerelles est automatiquement segmentée en morceaux de 256 Mo. Les segments seront stockés dans ce second conteneur et référencés par un fichier de 0 octet appelé manifeste dans le premier conteneur.

### Pourquoi mon fichier apparaît vide de 0 octet dans l’interface web alors que je l’ai transféré par scp/sftp/rsync ?

Comme indiqué précédemment, pour référencer tous les morceaux d’une archive segmentée, un manifeste est créé. Ce manifeste est parfois un fichier de 0 octet, où les informations utiles sont en fait stockées dans des métadonnées. C’est un peu comme un lien symbolique.

### Pourquoi est-ce que j’obtiens une erreur quand j’essaie de récupérer une archive avec rsync/scp/sftp ?

OVH Cloud Archive est une solution pour les données rarement consultées. Elle est optimisée pour offrir un prix très bas au détriment d’un délai de récupération. Avant d’accéder à une archive, vous devez la desceller.

### Comment desceller une archive ?

Le descellement d’une archive consiste à envoyer une demande de descellement, puis à interroger le traitement de l’opération.

Le descellement peut se faire par :

- L’interface client.
- L’API Openstack.
- Passerelles pour les protocoles basés sur SSH : faire une tentative de récupération de l’archive.

Le traitement de cette opération peut être interrogé avec :

- L’interface client](../pca_unlock/guide.fr-ca.md){.ref}.
- L’API Openstack.
