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




## Sauvegardes


## Curator



