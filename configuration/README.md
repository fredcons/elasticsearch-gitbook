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
/usr/share/elasticsearch/bin
/usr/share/elasticsearch/bin/elasticsearch
/usr/share/elasticsearch/bin/elasticsearch-systemd-pre-exec
/usr/share/elasticsearch/bin/elasticsearch.in.sh
/usr/share/elasticsearch/bin/plugin
/etc
/etc/elasticsearch
/etc/elasticsearch/elasticsearch.yml
/etc/elasticsearch/logging.yml
/etc/elasticsearch/scripts
/etc/default
/etc/default/elasticsearch
/usr/share/elasticsearch/lib
/usr/share/elasticsearch/lib/HdrHistogram-2.1.6.jar
/usr/share/elasticsearch/lib/apache-log4j-extras-1.2.17.jar
/usr/share/elasticsearch/lib/commons-cli-1.3.1.jar
/usr/share/elasticsearch/lib/compiler-0.8.13.jar
/usr/share/elasticsearch/lib/compress-lzf-1.0.2.jar
/usr/share/elasticsearch/lib/elasticsearch-2.2.0.jar
/usr/share/elasticsearch/lib/guava-18.0.jar
/usr/share/elasticsearch/lib/hppc-0.7.1.jar
/usr/share/elasticsearch/lib/jackson-core-2.6.2.jar
/usr/share/elasticsearch/lib/jackson-dataformat-cbor-2.6.2.jar
/usr/share/elasticsearch/lib/jackson-dataformat-smile-2.6.2.jar
/usr/share/elasticsearch/lib/jackson-dataformat-yaml-2.6.2.jar
/usr/share/elasticsearch/lib/jna-4.1.0.jar
/usr/share/elasticsearch/lib/joda-convert-1.2.jar
/usr/share/elasticsearch/lib/joda-time-2.8.2.jar
/usr/share/elasticsearch/lib/jsr166e-1.1.0.jar
/usr/share/elasticsearch/lib/jts-1.13.jar
/usr/share/elasticsearch/lib/log4j-1.2.17.jar
/usr/share/elasticsearch/lib/lucene-analyzers-common-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-backward-codecs-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-core-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-grouping-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-highlighter-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-join-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-memory-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-misc-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-queries-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-queryparser-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-sandbox-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-spatial-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-spatial3d-5.4.1.jar
/usr/share/elasticsearch/lib/lucene-suggest-5.4.1.jar
/usr/share/elasticsearch/lib/netty-3.10.5.Final.jar
/usr/share/elasticsearch/lib/securesm-1.0.jar
/usr/share/elasticsearch/lib/snakeyaml-1.15.jar
/usr/share/elasticsearch/lib/spatial4j-0.5.jar
/usr/share/elasticsearch/lib/t-digest-3.0.jar
/usr/share/elasticsearch/modules
/usr/share/elasticsearch/modules/lang-expression
/usr/share/elasticsearch/modules/lang-groovy
/usr/share/elasticsearch/modules/lang-expression/antlr4-runtime-4.5.1-1.jar
/usr/share/elasticsearch/modules/lang-expression/asm-5.0.4.jar
/usr/share/elasticsearch/modules/lang-expression/asm-commons-5.0.4.jar
/usr/share/elasticsearch/modules/lang-expression/lang-expression-2.2.0.jar
/usr/share/elasticsearch/modules/lang-expression/lucene-expressions-5.4.1.jar
/usr/share/elasticsearch/modules/lang-expression/plugin-descriptor.properties
/usr/share/elasticsearch/modules/lang-expression/plugin-security.policy
/usr/share/elasticsearch/modules/lang-groovy/groovy-all-2.4.4-indy.jar
/usr/share/elasticsearch/modules/lang-groovy/lang-groovy-2.2.0.jar
/usr/share/elasticsearch/modules/lang-groovy/plugin-descriptor.properties
/usr/share/elasticsearch/modules/lang-groovy/plugin-security.policy
/etc/init.d
/etc/init.d/elasticsearch
/usr/lib
/usr/lib/systemd
/usr/lib/systemd/system
/usr/lib/systemd/system/elasticsearch.service
/usr/lib/sysctl.d
/usr/lib/sysctl.d/elasticsearch.conf
/usr/lib/tmpfiles.d
/usr/lib/tmpfiles.d/elasticsearch.conf
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/elasticsearch
/usr/share/elasticsearch/NOTICE.txt
/usr/share/elasticsearch/README.textile
/usr/share/doc
/usr/share/doc/elasticsearch
/usr/share/doc/elasticsearch/copyright
/var
/var/lib
/var/lib/elasticsearch
/var/log
/var/log/elasticsearch
/usr/share/elasticsearch/plugins
/var/run
/var/run/elasticsearch
```

On voit donc que:
- la librairie elle-même est installée dans /usr/share/elasticsearch
- sa configuration est centralisée dans /etc/elasticsearch/
- le service elasticsearch est défini dans /etc/init.d, et sa configuration par défaut dans /etc/default/elasticsearch (une version systemd existe également)

## Démarrage du service

On va maintenant lancer le service, qui est délibérément maintenu stoppé au démarrage de la VM :

```
# service elasticsearch start 
 * Starting Elasticsearch Server [ OK ] 
# service elasticsearch status
 * elasticsearch is running
```

Voilà, le service est démarré, et on peut le constater en interrogeant le port http par défaut, 9200 :

```
# curl http://localhost:9200
{
  "name" : "Bentley Wittman",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "2.2.0",
    "build_hash" : "8ff36d139e16f8720f2947ef62c8167a888992fe",
    "build_timestamp" : "2016-01-27T13:32:39Z",
    "build_snapshot" : false,
    "lucene_version" : "5.4.1"
  },
  "tagline" : "You Know, for Search"
}


```

L'url racine nous donne donc des informations de base sur le serveur.

Toutes les actions que nous allons réaliser pendant ce hands-on utiliseront l'API HTTP.  
La plupart des langages possèdent un SDK pour intégrer l'usage d'ElasticSearch dans du code client, mais tout est réalisable par HTTP : par souci de simplification, nous allons donc nous baser sur ce mode de communication.

On peut aussi noter que le démarrage d'ES a créé un fichier de log, dans /var/log/elasticsearch/elasticsearch.log :

```
[2016-02-24 16:39:08,992][INFO ][node                     ] [Bentley Wittman] version[2.2.0], pid[7866], build[8ff36d1/2016-01-27T13:32:39Z]
[2016-02-24 16:39:08,992][INFO ][node                     ] [Bentley Wittman] initializing ...
[2016-02-24 16:39:09,489][INFO ][plugins                  ] [Bentley Wittman] modules [lang-expression, lang-groovy], plugins [head, kopf], sites [head, kopf]
[2016-02-24 16:39:09,512][INFO ][env                      ] [Bentley Wittman] using [1] data paths, mounts [[/ (/dev/mapper/precise64-root)]], net usable_space [71.3gb], net total_space [78.8gb], spins? [possibly], types [ext4]
[2016-02-24 16:39:09,512][INFO ][env                      ] [Bentley Wittman] heap size [1007.3mb], compressed ordinary object pointers [true]
[2016-02-24 16:39:11,260][INFO ][node                     ] [Bentley Wittman] initialized
[2016-02-24 16:39:11,260][INFO ][node                     ] [Bentley Wittman] starting ...
[2016-02-24 16:39:11,333][INFO ][transport                ] [Bentley Wittman] publish_address {10.0.2.15:9300}, bound_addresses {[::]:9300}
[2016-02-24 16:39:11,341][INFO ][discovery                ] [Bentley Wittman] elasticsearch/QQWg3JXSSyyjJuJs1Gtvbw
[2016-02-24 16:39:14,429][INFO ][cluster.service          ] [Bentley Wittman] new_master {Bentley Wittman}{QQWg3JXSSyyjJuJs1Gtvbw}{10.0.2.15}{10.0.2.15:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2016-02-24 16:39:14,458][INFO ][http                     ] [Bentley Wittman] publish_address {10.0.2.15:9200}, bound_addresses {[::]:9200}
[2016-02-24 16:39:14,458][INFO ][node                     ] [Bentley Wittman] started
[2016-02-24 16:39:14,488][INFO ][gateway                  ] [Bentley Wittman] recovered [0] indices into cluster_state
```

Il faudra régulièrement consulter ce fichier pour voir comment se comporte l'instance.

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
[2016-02-24 16:55:42,776][INFO ][plugins                  ] [Franz Kafka] modules [lang-expression, lang-groovy], plugins [head, kopf], sites [head, kopf]
```

ES propose un mécanisme de plugins qui permettent d'étendre ses capacités, et d'en faciliter l'exploitation.

Pendant longtemps, ES n'a proposé aucune interface graphique d'administration : cela a donné naissance à un certain nombre de plugins permettant de visualiser le contenu des index, de mesurer les performances, et autres tâches d'administration.

On a donc disponibles dans la VM :
- head, disponible sur http://localhost:9200/_plugin/head/
- kopf, disponible sur http://localhost:9200/_plugin/kopf/

## Kibana

Kibana est un autre produit de la société Elastic : il permet de réaliser des visualisations complexes sur tous types d'index, notamment des index logstash.  
Mais ce n'est pas forcément ce qui va nous intéresser ici : on va installer son plugin `sense`, qui permet de requêter Elasticsearch à travers un browser.  
On va d'abord démarrer Kibana : 

```
service kibana start
```   

On peut ensuite aller sur http://localhost:5601/app/sense

On pourra donc durant ce hands-on utiliser au choix Sense (de préférence), ou `curl` dans son terminal.

On notera que les ports 9200 et 5601 de la VM sont rendus disponibles sur la machine hôte : on peut donc utiliser ces plugins dans son navigateur, et toutes les commandes curl / http à venir seront exploitables depuis la machine hôte.












