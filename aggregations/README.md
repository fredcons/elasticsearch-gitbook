# Agrégations

Outre sa fonction de moteur de recherche, Elasticsearch offre des fonctionnalités statistiques assez poussées : à travers son système d'agrégations, il est possible d'explorer les données à travers des métriques, ou d'offrir à un utilisateur des facettes de navigation sur un jeu de données.


## Les concepts

Les agrégations peuvent être de deux types :
- le type "buckets" : les "buckets" sont des "catégories" dans lequelles on va ranger les résultats, et associer à chaque catégorie un compteur.
- le type "metric", qui offre une ou plusieurs valeurs obtenues à partir des résultats de l'agrégation, par exemple leur nombre, la valeur max, etc... 

Il est à noter que ce système d'agrégation peut être utilisé seul, ou en combinaison avec une recherche textuelle ou toute autre query.  
Par ailleurs, on peut demander plusieurs agrégations dans une seule requête, ou des agrégations hiérarchiques (c'est-à-dire imbriquées les une dans les autres, possiblement en combinant des buckets et des metrics).

## Structure d'une agrégation

Une agrégation se définit dans un document JSON similaire à celui d'une requête.

Voici un exemple d'agrégation "buckets", qui compte le nombre de startups pour chaque tag :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size" : 0,
  "aggs" : {
    "tags" : {
      "terms" : {
        "field" : "tag_list"
      }
    }
  }
}'
```

Le "size: 0" permet de ne pas afficher les résultats de la requête implicite (un `match_all`).
On obtient un résultat avec pour chacun des 10 termes les plus courants (nombre et ordre par défaut) le nombre d'entreprises correspondant.

```
{
  "took" : 29,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 18794,
    "max_score" : 0.0,
    "hits" : [ ]
  },
  "aggregations" : {
    "tags" : {
      "doc_count_error_upper_bound" : 103,
      "sum_other_doc_count" : 60600,
      "buckets" : [ {
        "key" : "mobile",
        "doc_count" : 522
      }, {
        "key" : "video",
        "doc_count" : 373
      }, {
        "key" : "software",
        "doc_count" : 342
      }, {
        "key" : "social-network",
        "doc_count" : 336
      }, {
        "key" : "saas",
        "doc_count" : 327
      }, {
        "key" : "advertising",
        "doc_count" : 319
      }, {
        "key" : "social-networking",
        "doc_count" : 294
      }, {
        "key" : "search",
        "doc_count" : 289
      }, {
        "key" : "social",
        "doc_count" : 283
      }, {
        "key" : "music",
        "doc_count" : 279
      } ]
    }
  }
}
```

Ici, les "buckets" sont donc chacun des éléments "key", et la métrique est le "doc_count" associé.

On peut également exécuter cette agrégation dans le contexte d'une requête.
Exemple: le top 10 des tags pour les startups fondées en 2011

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size" : 0,
  "query" : {
    "filtered" : {
      "filter" : {
        "term" : { "founded_year" : 2011 }
      }
    }
  },
  "aggs" : {
    "tags" : {
      "terms" : {
        "field" : "tag_list"
      }
    }
  }
}'
```

## Exercices

Afin de répondre à ces questions, on pourra se baser sur [le guide des agrégations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html) et ses pages filles.

#### Exercice 5.1

Obtenir des statistiques sur le champ `number_of_employees` : min, max avg, et les percentiles 1, 5, 25, 50, 75, 95, 99, 99.9

#### Exercice 5.2

Obtenir un histogramme du nombre d'IPO par année (champ `ipo.pub_year`), puis par décennie.

#### Exercice 5.3

Obtenir pour les entreprises fondéees entre 2000 et 2015 (`founded_year`) les 5 tags (`tag_list`) les plus utilisés pour chaque année

#### Exercice 5.4

Dans la même requête, rechercher les entreprises dont l'IPO a été réalisée en 2012`, et afficher le nombre d'IPO par année (champ `ipo.pub_year`) pour les entreprises fondées entre 2000 et 2015.
