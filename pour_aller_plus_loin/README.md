# Pour aller plus loin

Cette introduction n'a fait que présenter les concepts centraux d'Elasticsearch : contenu du package, gestion des schémas, recherches et agrégations.

Mais Elasticsearch est un produit extrêmement riche et complexe : vous trouverez ci-dessous différents concepts et features à creuser pour aller plus loin.

Notons que la documentation d'Elasticsearch se découpe en :
- une [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html), qui expose les différentes briques et leur paramétrage
- un [guide](https://www.elastic.co/guide/en/elasticsearch/guide/master/index.html) qui propose une approche plus narrative (version HTML d'un livre publié chez O'Reilly).
Les liens ci-dessous sont issus de ces deux sources.

## Recherche avancée

Au-delà de la simple recherche textuelle, Elasticsearch propose des modules pour enrichir l'expérience utilisateur :
- [gestion de synonymes](https://www.elastic.co/guide/en/elasticsearch/guide/master/synonyms.html)
- [stemming par langue](https://www.elastic.co/guide/en/elasticsearch/guide/master/stemming.html)
- [suggestion de termes](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters.html)
- plus généralement des [modules d'analyse textuelle](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html) très puissants

Par ailleurs, il ne se limite pas aux recherches textuelles, mais permet aussi de réaliser des [recherches géographiques](https://www.elastic.co/guide/en/elasticsearch/guide/master/geoloc.html), à la fois à travers des queries, mais aussi des agrégations.

## Scoring

On a vu qu'il était possible de donner des pondérations différentes à des champs lors du calcul du score d'une recherche. ES propose d'autres possibilités de calcul de scoring (combinaison de champs, scripting, divers algorithmes de scoring).

[Ce chapitre](https://www.elastic.co/guide/en/elasticsearch/guide/master/controlling-relevance.html) propose une explication en profondeur des différentes possibilités.

## Fonctionnement et administration d'un cluster

On a travaillé sur une seule instance d'ES, mais c'est un produit pour fonctionner en cluster.
Il est donc impératif de comprendre comment se répartissent les documents dans un index et dans un  cluster, quel est le parcours d'une requête ou d'indexation.

[Ces](https://www.elastic.co/guide/en/elasticsearch/guide/master/distributed-cluster.html) [quatre](https://www.elastic.co/guide/en/elasticsearch/guide/master/distributed-docs.html) [chapitres](https://www.elastic.co/guide/en/elasticsearch/guide/master/distributed-search.html) [techniques](https://www.elastic.co/guide/en/elasticsearch/guide/master/inside-a-shard.html) fournissent des réponses à ces questions.

Par ailleurs, l'[exploitation d'ES en production](https://www.elastic.co/guide/en/elasticsearch/guide/master/administration.html) mérite aussi un peu de lecture.

## ELK

ELK est la combinaison de Elasticsearch, Kibana (interface de visualisation d'index) et Logstash (brique de collecte et enrichissement de données).

Ensemble, ces trois produits forment une solution populaire de gestion centralisée de logs.
On trouvera [ici](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-4-on-ubuntu-14-04) une série de tutoriaux pour installer l'ensemble.



