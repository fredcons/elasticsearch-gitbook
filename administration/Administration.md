# Administration

Tout comme pour les recherches, l'administration d'Elasticsearch peut s'effectuer intégralement par des requêtes HTTP.  
D'autres outils (plugins, utilitaires en ligne de commande) sont là pour faciliter les choses.


## Etat du cluster

Deux API existent pour interroger l'état du cluster

### L'API `cat`

L'API [`cat`](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html) permet d'obtenir des informations non pas sous forme de JSON, mais sous forme tabluaire, donc plus compacte et plus simple à digérer.

#### Exercice 7.1

Lister les noeuds du cluster local

#### Exercice 7.2

Lister les indices du cluster local


### L'API `cluster` et `indice`

L'API [`cluster`](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html) permet d'obtenir des informations similaires, mais formattées en JSON, et souvent plus détaillées.

#### Exercice 7.3

Afficher la santé du cluster

#### Exercice 7.4

Afficher les statistiques sur le cluster, puis sur les noeuds.

## Mise à jour des settings

On a vu ci-dessus plusieurs manières d'obtenir des informations d'un cluster ou d'un index. Mais un cluster peut également être modifié via l'API de [`settings`](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html).
De la même manière, les settings d'un index peuvent être modifiés via [l'API d'update d'index](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html)

#### Exercice 7.5

Passer le nombre de replica de l'index crunchbase à 1.  
Quel est l'effet sur la santé du cluster ? 

## Alias

Un alias dans Elasticsearch a deux fonctions : 
- fournir un autre nom à un index existant. Cela peut-être utile pour avoir un point d'entrée unique pour les applications clientes, tout en changeant l'index effectivement rendu visible. Exemple : avoir un index /products qui pointe vers /products_20160317, puis vers /products_20160318, sans interruption pour l'application cliente.
- fournir une vue "filtrée" d'un index existant en ajoutant une contrainte dans sa définition. 

[La documentation d'`alias`](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html) fournit tous les détails de cette API indispensable.


## Sauvegardes

Même si un index Elasticsearch est répliqué sur plusieurs machines, ces replica n'ont pas valeur de sauvegarde.  

Elasticsearch propose à cet effet un mécanisme de `snapshot`, qui fonctionne en deux temps:
- définition d'un repository, soit l'emplacement du stockage des snapshots. Cela peut être un empalcement disque, un emplacement HDFS, ou un bucket S3 ou Azure Cloud Storage
- prise de snapshot via l'API (équivalent d'un export)

Une fois un snapshot pris, on pourra le réimporter dans un index via la même API.


## Curator

`curator` est l'outil officiel de la société Elastic pour administrer ses indices.  
A la base prévu pour supprimer des indices sur la base de leur nom ou de leur timestamp, il a été étendu pour réaliser d'autres tâches (dont la gestion des alais et des snapshots.

L'étendue des commandes disponibles est visible ci-dessous : 

```
curator
Usage: curator [OPTIONS] COMMAND [ARGS]...

  Curator for Elasticsearch indices.

  See http://elastic.co/guide/en/elasticsearch/client/curator/current

Options:
  --host TEXT         Elasticsearch host.
  --url_prefix TEXT   Elasticsearch http url prefix.
  --port INTEGER      Elasticsearch port.
  --use_ssl           Connect to Elasticsearch through SSL.
  --certificate TEXT  Path to certificate to use for SSL validation.
                      (OPTIONAL)
  --ssl-no-validate   Do not validate SSL certificate
  --http_auth TEXT    Use Basic Authentication ex: user:pass
  --timeout INTEGER   Connection timeout in seconds.
  --master-only       Only operate on elected master node.
  --dry-run           Do not perform any changes.
  --debug             Debug mode
  --loglevel TEXT     Log level
  --logfile TEXT      log file
  --logformat TEXT    Log output format [default|logstash].
  --quiet             Suppress command-line output.
  --version           Show the version and exit.
  --help              Show this message and exit.

Commands:
  alias       Index Aliasing
  allocation  Index Allocation
  bloom       Disable bloom filter cache
  close       Close indices
  delete      Delete indices or snapshots
  open        Open indices
  optimize    Optimize Indices
  replicas    Replica Count Per-shard
  seal        Seal indices (Synced flush: ES 1.6.0+ only)
  show        Show indices or snapshots
  snapshot    Take snapshots of indices (Backup)
```



