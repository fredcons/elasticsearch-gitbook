# Configuration

La VM est installée, mais aucun service n'est démarré.
Après avoir exécuté un `vagrant ssh`, on va passer root, et démarrer Elasticsearch

## Contenu du package

D'abord, utiliser le user root (ce sera l'utilisateur de référence pour la suite du hands-on)

```
sudo su -
```

On va examiner le package qui nous intéresse :

```
# dpkg-query -L elasticsearch
/usr
/usr/share
/usr/share/elasticsearch
/usr/share/elasticsearch/NOTICE.txt
/usr/share/elasticsearch/README.textile
/usr/share/elasticsearch/bin
/usr/share/elasticsearch/bin/elasticsearch
/usr/share/elasticsearch/bin/elasticsearch.in.sh
/usr/share/elasticsearch/bin/plugin
/usr/share/elasticsearch/lib
/usr/share/elasticsearch/lib/elasticsearch-1.5.1.jar
/usr/share/elasticsearch/lib/sigar
/usr/share/elasticsearch/lib/sigar/libsigar-amd64-linux.so
/usr/share/elasticsearch/lib/sigar/libsigar-ia64-linux.so
/usr/share/elasticsearch/lib/sigar/libsigar-x86-linux.so
/usr/share/elasticsearch/lib/sigar/sigar-1.6.4.jar
/usr/share/elasticsearch/lib/antlr-runtime-3.5.jar
/usr/share/elasticsearch/lib/apache-log4j-extras-1.2.17.jar
/usr/share/elasticsearch/lib/asm-4.1.jar
/usr/share/elasticsearch/lib/asm-commons-4.1.jar
/usr/share/elasticsearch/lib/groovy-all-2.4.0.jar
/usr/share/elasticsearch/lib/jna-4.1.0.jar
/usr/share/elasticsearch/lib/jts-1.13.jar
/usr/share/elasticsearch/lib/log4j-1.2.17.jar
/usr/share/elasticsearch/lib/lucene-analyzers-common-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-core-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-expressions-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-grouping-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-highlighter-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-join-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-memory-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-misc-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-queries-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-queryparser-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-sandbox-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-spatial-4.10.4.jar
/usr/share/elasticsearch/lib/lucene-suggest-4.10.4.jar
/usr/share/elasticsearch/lib/spatial4j-0.4.1.jar
/etc
/etc/default
/etc/default/elasticsearch
/etc/init.d
/etc/init.d/elasticsearch
/usr/lib
/usr/lib/systemd
/usr/lib/systemd/system
/usr/lib/systemd/system/elasticsearch.service
/etc/elasticsearch
/etc/elasticsearch/elasticsearch.yml
/etc/elasticsearch/logging.yml
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/elasticsearch
/usr/share/doc
/usr/share/doc/elasticsearch
/usr/share/doc/elasticsearch/copyright
```

On voit donc que:
- la librairie elle-même est installée dans /usr/share/elasticsearch
- sa configuration est centralisée dans /etc/elasticsearch/
- le service elasticsearch est défini dans /etc/init.d, et sa configuration par défaut dans /etc/default/elasticsearch (une version systemd existe également)

## Démarrage du service

On va maintenant lancer le service, qui est délibérément maintenu stoppé au démarrage de la VM :

```
 # service elasticsearch start
 * Starting Elasticsearch Server
 # service elasticsearch status
 * elasticsearch is running
```

Voilà, le service est démarré, et on peut le constater en interrogeant le port http par défaut, 9200 :

```
# curl http://localhost:9200
{
  "status" : 200,
  "name" : "Zuras",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.5.1",
    "build_hash" : "5e38401bc4e4388537a615569ac60925788e1cf4",
    "build_timestamp" : "2015-04-09T13:41:35Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}

```

L'url racine nous donne donc des informations de base sur le serveur.

Toutes les actions que nous allons réaliser pendant ce hands-on utiliseront l'API HTTP. La plupart des langages possèdent un SDK pour intégrer l'usage d'ElasticSearch dans du code client, mais tout est réalisable par HTTP : par souci de simplification, nous allons donc nous baser sur ce mode de communication.

On peut aussi noter que le démarrage d'ES a créé un fichier de log, dans /var/log/elasticsearch/elasticsearch.log :

```
[2015-04-17 14:46:30,535][INFO ][node                     ] [Zuras] version[1.5.1], pid[1529], build[5e38401/2015-04-09T13:41:35Z]
[2015-04-17 14:46:30,535][INFO ][node                     ] [Zuras] initializing ...
[2015-04-17 14:46:30,554][INFO ][plugins                  ] [Zuras] loaded [marvel], sites [marvel, bigdesk, head]
[2015-04-17 14:46:33,925][INFO ][node                     ] [Zuras] initialized
[2015-04-17 14:46:33,927][INFO ][node                     ] [Zuras] starting ...
[2015-04-17 14:46:34,312][INFO ][transport                ] [Zuras] bound_address {inet[/0:0:0:0:0:0:0:0:9300]}, publish_address {inet[/10.0.2.15:9300]}
[2015-04-17 14:46:34,361][INFO ][discovery                ] [Zuras] elasticsearch/9YZCD_G_R1CCyrP9rBsOiw
[2015-04-17 14:46:38,206][INFO ][cluster.service          ] [Zuras] new_master [Zuras][9YZCD_G_R1CCyrP9rBsOiw][precise64][inet[/10.0.2.15:9300]], reason: zen-disco-join (elected_as_master)
```

Il faudra régulièrement consulter ce fichier pour voir comment se comporte l'instance.

Par ailleurs, ES a également créé un dossier /var/lib/elasticsearch, dans lequel seront créés les fichiers physiques des index.

## Exploration des fichiers de configuration

Le fichier principal de configuration est /etc/elasticsearch/elasticsearch.yml, ouvrons le pour l'explorer :

```
# vim /etc/elasticsearch/elasticsearch.yml
```

On va commencer par modifier deux paramètres centraux :
- le nom du cluster :

```
# cluster.name: elasticsearch
cluster.name: handson
```

- le nom du noeud :

```
# node.name: Franz Kafka
node.name: Franz Kafka
```

On redémarre ensuite ES, et on peut voir que les logs et dossiers de stockage sont contextualisés :

```
# service elasticsearch restart
# less /var/log/elasticsearch/handson.log
# tree /var/lib/elasticsearch/handson/
```

## Des plugins pour nous aider

On a pu voir dans la log de démarrage :

```
[2015-04-17 15:00:12,243][INFO ][plugins                  ] [Franz Kafka] loaded [marvel], sites [marvel, bigdesk, head]
```

ES propose un mécanisme de plugins qui permettent d'étendre ses capacités, et d'en faciliter l'exploitation.

Pendant longtemps, ES n'a proposé aucune interface graphique d'administration : cela a donné naissance à un certain nombre de plugins permettant de visualiser le contenu des index, de mesurer les performances, et autres tâches d'administration.

On a donc disponibles dans la VM :
- head, disponible sur http://localhost:9200/_plugin/head/
- bigdesk, disponible sur http://localhost:9200/_plugin/bigdesk/

Plus récemment, ES a développé son propre plugin d'administration, Marvel, produit payant pour la production, mais gratuit sur des machines de développement. Il est disponible sur http://localhost:9200/_plugin/marvel/.

On notera que le port 9200 de la VM est disponible sur la machine hôte : on peut donc utiliser ces plugins dans son navigateur, et toutes les commandes curl à venir seront exploitables depuis la machine hôte.












